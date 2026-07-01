param(
    [ValidateSet('Docker', 'Local')]
    [string]$Mode = 'Docker',

    [string]$ProjectRoot = '',
    [string]$PsqlExe = 'psql',
    [string]$HostName = 'localhost',
    [int]$Port = 5432,
    [string]$DatabaseName = 'prova_db_26',
    [string]$UserName = 'postgres',
    [string]$Password = '',
    [string]$ContainerName = 'prova_db_26_showcase_temp',
    [switch]$Cleanup
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:StepStatus = [ordered]@{}
$script:CurrentStep = ''
$script:DockerStarted = $false
$script:HadPreviousPassword = $false
$script:PreviousPassword = ''
$script:ExitCode = 0

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message"
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[OK] $Message"
}

function Write-Fail {
    param([string]$Message)
    Write-Host "[FAIL] $Message"
}

function Show-Section {
    param([string]$Title)
    Write-Host ''
    Write-Host "===== $Title ====="
}

function Set-StepStatus {
    param(
        [string]$Step,
        [string]$Status
    )

    $script:StepStatus[$Step] = $Status
}

function Assert-NotBlank {
    param(
        [string]$Name,
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "Parametro obrigatorio vazio: $Name"
    }
}

function Assert-PositivePort {
    param([int]$Value)

    if (($Value -lt 1) -or ($Value -gt 65535)) {
        throw "Porta invalida: $Value"
    }
}

function Resolve-ProjectRootPath {
    if (-not [string]::IsNullOrWhiteSpace($ProjectRoot)) {
        return (Resolve-Path -LiteralPath $ProjectRoot).Path
    }

    if (($null -ne $PSScriptRoot) -and (-not [string]::IsNullOrWhiteSpace($PSScriptRoot))) {
        return (Resolve-Path -LiteralPath $PSScriptRoot).Path
    }

    throw 'Nao foi possivel determinar a raiz do projeto.'
}

function Assert-Tool {
    param([string]$ToolName)

    $command = Get-Command $ToolName -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        throw "Ferramenta nao encontrada: $ToolName"
    }
}

function Assert-File {
    param([string]$FilePath)

    if (([string]::IsNullOrWhiteSpace($FilePath)) -or (-not (Test-Path -LiteralPath $FilePath))) {
        throw "Arquivo nao encontrado: $FilePath"
    }
}

function Save-CurrentPasswordState {
    if (Test-Path Env:PGPASSWORD) {
        $script:HadPreviousPassword = $true
        $script:PreviousPassword = $env:PGPASSWORD
    }
}

function Set-LocalPasswordIfProvided {
    if (-not [string]::IsNullOrWhiteSpace($Password)) {
        $env:PGPASSWORD = $Password
    }
}

function Restore-PasswordState {
    if ($script:HadPreviousPassword) {
        $env:PGPASSWORD = $script:PreviousPassword
    }
    elseif (Test-Path Env:PGPASSWORD) {
        Remove-Item Env:PGPASSWORD
    }
}

function Invoke-DockerCommand {
    param([string[]]$Arguments)

    & docker @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao executar docker $($Arguments -join ' ')"
    }
}

function Copy-SqlToContainer {
    param([string]$SqlFile)

    $destPath = '/tmp/trae_showcase_current.sql'
    & docker cp $SqlFile "${ContainerName}:${destPath}"
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao copiar arquivo para o container: $SqlFile"
    }
    return $destPath
}

function Get-ExistingContainerId {
    $containerId = & docker ps -a --filter "name=^/${ContainerName}$" --format "{{.ID}}"
    if ($LASTEXITCODE -ne 0) {
        throw 'Falha ao verificar containers existentes.'
    }

    if ([string]::IsNullOrWhiteSpace($containerId)) {
        return ''
    }

    return $containerId.Trim()
}

function Get-ContainerLabelValue {
    param([string]$ContainerId)

    $inspectJson = & docker inspect $ContainerId
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao inspecionar container: $ContainerId"
    }

    $inspectData = $inspectJson | ConvertFrom-Json
    if (($null -eq $inspectData) -or ($inspectData.Count -lt 1)) {
        throw "Nao foi possivel ler os metadados do container: $ContainerId"
    }

    $labels = $inspectData[0].Config.Labels
    if ($null -eq $labels) {
        return ''
    }

    $labelValue = $labels.'trae-showcase'
    if ($null -eq $labelValue) {
        return ''
    }

    return [string]$labelValue
}

function Remove-ShowcaseContainerIfOwned {
    $containerId = Get-ExistingContainerId
    if ([string]::IsNullOrWhiteSpace($containerId)) {
        return
    }

    $labelValue = Get-ContainerLabelValue -ContainerId $containerId
    if ($labelValue.Trim() -ne '1') {
        throw "Ja existe um container com esse nome e ele nao pertence ao showcase: $ContainerName"
    }

    Write-Info "Removendo container anterior do showcase: $ContainerName"
    Invoke-DockerCommand -Arguments @('rm', '-f', $ContainerName)
}

function Start-DockerDatabase {
    Remove-ShowcaseContainerIfOwned

    Write-Info 'Iniciando PostgreSQL temporario com Docker'
    Invoke-DockerCommand -Arguments @(
        'run',
        '--name', $ContainerName,
        '--label', 'trae-showcase=1',
        '-e', 'POSTGRES_PASSWORD=postgres',
        '-e', "POSTGRES_DB=$DatabaseName",
        '-d',
        'postgres:17-alpine'
    )

    $script:DockerStarted = $true

    $consecutiveOk = 0
    $requiredConsecutive = 3

    for ($attempt = 1; $attempt -le 45; $attempt++) {
        # Verificar se o container ainda esta rodando
        $running = & docker inspect --format '{{.State.Running}}' $ContainerName 2>$null
        if ($running -ne 'true') {
            $consecutiveOk = 0
            Start-Sleep -Seconds 2
            continue
        }

        $null = & docker exec -u postgres $ContainerName pg_isready -U $UserName -d $DatabaseName 2>$null
        if ($LASTEXITCODE -ne 0) {
            $consecutiveOk = 0
            Start-Sleep -Seconds 2
            continue
        }

        # pg_isready OK: validar com SELECT 1 para garantir estabilidade
        $null = & docker exec -u postgres $ContainerName psql -X -U $UserName -d $DatabaseName -c 'SELECT 1' 2>$null
        if ($LASTEXITCODE -ne 0) {
            $consecutiveOk = 0
            Start-Sleep -Seconds 2
            continue
        }

        $consecutiveOk++
        if ($consecutiveOk -ge $requiredConsecutive) {
            Write-Ok 'PostgreSQL pronto para uso'
            return
        }

        Start-Sleep -Seconds 1
    }

    throw 'O PostgreSQL nao ficou pronto dentro do tempo esperado.'
}

function Stop-DockerDatabase {
    $containerId = Get-ExistingContainerId
    if ([string]::IsNullOrWhiteSpace($containerId)) {
        return
    }

    $labelValue = Get-ContainerLabelValue -ContainerId $containerId
    if ($labelValue.Trim() -eq '1') {
        Write-Info "Removendo container do showcase: $ContainerName"
        Invoke-DockerCommand -Arguments @('rm', '-f', $ContainerName)
    }
}

function Invoke-PsqlFile {
    param([string]$SqlFile)

    Assert-File -FilePath $SqlFile

    if ($Mode -eq 'Docker') {
        $containerSqlPath = Copy-SqlToContainer -SqlFile $SqlFile
        & docker exec -u postgres $ContainerName psql -X -v 'ON_ERROR_STOP=1' -P 'pager=off' -U $UserName -d $DatabaseName -f $containerSqlPath
    }
    else {
        & $PsqlExe `
            -X `
            -v 'ON_ERROR_STOP=1' `
            -P 'pager=off' `
            -h $HostName `
            -p $Port `
            -U $UserName `
            -d $DatabaseName `
            -f $SqlFile
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao executar arquivo SQL: $SqlFile"
    }
}

function Invoke-PsqlCommand {
    param(
        [string]$Label,
        [string]$SqlText
    )

    if ([string]::IsNullOrWhiteSpace($SqlText)) {
        throw "SQL vazio em: $Label"
    }

    if ($Mode -eq 'Docker') {
        & docker exec -u postgres $ContainerName psql -X -v 'ON_ERROR_STOP=1' -P 'pager=off' -U $UserName -d $DatabaseName -c $SqlText
    }
    else {
        & $PsqlExe `
            -X `
            -v 'ON_ERROR_STOP=1' `
            -P 'pager=off' `
            -h $HostName `
            -p $Port `
            -U $UserName `
            -d $DatabaseName `
            -c $SqlText
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao executar SQL: $Label"
    }
}

function Test-LocalConnection {
    Set-LocalPasswordIfProvided
    Write-Info 'Testando conexao local com PostgreSQL'
    Invoke-PsqlCommand -Label 'connection check' -SqlText 'SELECT current_database() AS database_name, current_user AS user_name;'
    Write-Ok 'Conexao local validada'
}

function Show-StepSummary {
    Show-Section -Title 'RESUMO'
    foreach ($entry in $script:StepStatus.GetEnumerator()) {
        Write-Host ("{0,-20} {1}" -f $entry.Key, $entry.Value)
    }
}

Save-CurrentPasswordState

$projectDir = Resolve-ProjectRootPath
$scriptsDir = Join-Path $projectDir 'scripts'
$seedDir = Join-Path $scriptsDir 'seed'
$queriesDir = Join-Path $projectDir 'queries'

$requiredFiles = [ordered]@{
    'setup' = (Join-Path $scriptsDir 'setup.sql')
    'validation' = (Join-Path $scriptsDir 'validacao.sql')
    'seed_users' = (Join-Path $seedDir '01_usuarios.sql')
    'seed_tags' = (Join-Path $seedDir '02_tags.sql')
    'seed_tasks' = (Join-Path $seedDir '03_tarefas.sql')
    'seed_task_tags' = (Join-Path $seedDir '04_tarefa_tags.sql')
    'queries_crud' = (Join-Path $queriesDir 'crud.sql')
    'queries_advanced' = (Join-Path $queriesDir 'consultas_avancadas.sql')
    'queries_aggregations' = (Join-Path $queriesDir 'agregacoes.sql')
}

$selectedQueries = @(
    @{
        Label = 'contagem de registros'
        Sql = @'
SELECT 'usuarios' AS entidade, COUNT(*) AS total FROM usuarios
UNION ALL
SELECT 'tags', COUNT(*) FROM tags
UNION ALL
SELECT 'tarefas', COUNT(*) FROM tarefas
UNION ALL
SELECT 'tarefa_tags', COUNT(*) FROM tarefa_tags
ORDER BY entidade;
'@
    },
    @{
        Label = 'tarefas recentes por usuario'
        Sql = @'
SELECT id, titulo, concluida, created_at
FROM tarefas
WHERE usuario_id = 1
ORDER BY created_at DESC
LIMIT 5;
'@
    },
    @{
        Label = 'filtro por tag'
        Sql = @'
SELECT DISTINCT t.id, t.titulo, t.concluida, t.created_at
FROM tarefas t
JOIN tarefa_tags tt ON t.id = tt.tarefa_id
JOIN tags tag ON tag.id = tt.tag_id
WHERE tag.nome = 'urgente'
  AND t.usuario_id = 1
ORDER BY t.created_at DESC;
'@
    },
    @{
        Label = 'filtro por periodo'
        Sql = @'
SELECT id, titulo, concluida, created_at
FROM tarefas
WHERE usuario_id = 1
  AND created_at >= '2026-06-20 00:00:00'
  AND created_at < '2026-07-01 00:00:00'
ORDER BY created_at DESC;
'@
    },
    @{
        Label = 'estatisticas por usuario'
        Sql = @'
SELECT
    u.email,
    COUNT(t.id) AS total_tarefas,
    SUM(CASE WHEN t.concluida THEN 1 ELSE 0 END) AS tarefas_concluidas,
    SUM(CASE WHEN NOT t.concluida THEN 1 ELSE 0 END) AS tarefas_pendentes
FROM usuarios u
LEFT JOIN tarefas t ON u.id = t.usuario_id
GROUP BY u.email
ORDER BY total_tarefas DESC, u.email ASC
LIMIT 5;
'@
    },
    @{
        Label = 'ranking de tags'
        Sql = @'
SELECT
    tag.nome,
    COUNT(tt.tarefa_id) AS total_usos
FROM tags tag
LEFT JOIN tarefa_tags tt ON tag.id = tt.tag_id
GROUP BY tag.nome
ORDER BY total_usos DESC, tag.nome ASC
LIMIT 10;
'@
    }
)

$selectedExplains = @(
    @{
        Label = 'plano de login por email'
        Sql = @'
EXPLAIN ANALYZE
SELECT id, email, senha, created_at, updated_at
FROM usuarios
WHERE email = 'admin@todo.com';
'@
    },
    @{
        Label = 'plano de tarefas por usuario'
        Sql = @'
EXPLAIN ANALYZE
SELECT id, titulo, descricao, concluida, created_at, updated_at
FROM tarefas
WHERE usuario_id = 1
ORDER BY created_at DESC
LIMIT 5;
'@
    },
    @{
        Label = 'plano de filtro por tag'
        Sql = @'
EXPLAIN ANALYZE
SELECT DISTINCT
    t.id,
    t.titulo,
    t.descricao,
    t.concluida,
    t.created_at
FROM tarefas t
JOIN tarefa_tags tt ON t.id = tt.tarefa_id
JOIN tags tag ON tt.tag_id = tag.id
WHERE tag.nome = 'urgente'
  AND t.usuario_id = 1
ORDER BY t.created_at DESC;
'@
    }
)

$extraValidationQueries = @(
    @{
        Label = 'contagens exatas'
        Sql = @'
SELECT
    (SELECT COUNT(*) FROM usuarios) AS usuarios,
    (SELECT COUNT(*) FROM tags) AS tags,
    (SELECT COUNT(*) FROM tarefas) AS tarefas,
    (SELECT COUNT(*) FROM tarefa_tags) AS tarefa_tags;
'@
    },
    @{
        Label = 'verificacao de orfaos'
        Sql = @'
SELECT COUNT(*) AS relacionamentos_orfaos
FROM tarefa_tags tt
LEFT JOIN tarefas t ON t.id = tt.tarefa_id
LEFT JOIN tags tag ON tag.id = tt.tag_id
WHERE t.id IS NULL OR tag.id IS NULL;
'@
    }
)

try {
    $script:CurrentStep = 'pre-checagem'
    Show-Section -Title 'PRE-CHECAGEM'

    Assert-NotBlank -Name 'Mode' -Value $Mode
    Assert-NotBlank -Name 'DatabaseName' -Value $DatabaseName
    Assert-NotBlank -Name 'UserName' -Value $UserName
    Assert-PositivePort -Value $Port

    if ($Mode -eq 'Docker') {
        Assert-NotBlank -Name 'ContainerName' -Value $ContainerName
        Assert-Tool -ToolName 'docker'
    }
    else {
        Assert-NotBlank -Name 'HostName' -Value $HostName
        Assert-NotBlank -Name 'PsqlExe' -Value $PsqlExe
        Assert-Tool -ToolName $PsqlExe
    }

    foreach ($file in $requiredFiles.GetEnumerator()) {
        Assert-File -FilePath $file.Value
    }

    Write-Ok 'Parametros e arquivos validados'
    Set-StepStatus -Step 'pre-checagem' -Status 'OK'

    $script:CurrentStep = 'inicializacao'
    Show-Section -Title 'INICIALIZACAO'

    if ($Mode -eq 'Docker') {
        Start-DockerDatabase
    }
    else {
        Test-LocalConnection
    }

    Set-StepStatus -Step 'inicializacao' -Status 'OK'

    $script:CurrentStep = 'carga'
    Show-Section -Title 'CARGA'
    Invoke-PsqlFile -SqlFile $requiredFiles['setup']
    Write-Ok 'Arquivo setup.sql aplicado'

    Invoke-PsqlFile -SqlFile $requiredFiles['seed_users']
    Write-Ok 'Arquivo 01_usuarios.sql aplicado'

    Invoke-PsqlFile -SqlFile $requiredFiles['seed_tags']
    Write-Ok 'Arquivo 02_tags.sql aplicado'

    Invoke-PsqlFile -SqlFile $requiredFiles['seed_tasks']
    Write-Ok 'Arquivo 03_tarefas.sql aplicado'

    Invoke-PsqlFile -SqlFile $requiredFiles['seed_task_tags']
    Write-Ok 'Arquivo 04_tarefa_tags.sql aplicado'
    Set-StepStatus -Step 'carga' -Status 'OK'

    $script:CurrentStep = 'analise'
    Show-Section -Title 'ANALYZE'
    Invoke-PsqlCommand -Label 'analyze' -SqlText 'ANALYZE;'
    Write-Ok 'Estatisticas atualizadas'
    Set-StepStatus -Step 'analise' -Status 'OK'

    $script:CurrentStep = 'validacao'
    Show-Section -Title 'VALIDACAO'
    Invoke-PsqlFile -SqlFile $requiredFiles['validation']
    Write-Ok 'Validacao estrutural concluida com sucesso'

    foreach ($query in $extraValidationQueries) {
        Write-Info ([string]$query.Label)
        Invoke-PsqlCommand -Label ([string]$query.Label) -SqlText ([string]$query.Sql)
        Write-Ok ([string]$query.Label)
    }

    Set-StepStatus -Step 'validacao' -Status 'OK'

    $script:CurrentStep = 'demonstracao'
    Show-Section -Title 'DEMONSTRACAO'
    foreach ($query in $selectedQueries) {
        Write-Info ([string]$query.Label)
        Invoke-PsqlCommand -Label ([string]$query.Label) -SqlText ([string]$query.Sql)
        Write-Ok ([string]$query.Label)
    }
    Set-StepStatus -Step 'demonstracao' -Status 'OK'

    $script:CurrentStep = 'plano_execucao'
    Show-Section -Title 'PLANO DE EXECUCAO'
    foreach ($query in $selectedExplains) {
        Write-Info ([string]$query.Label)
        Invoke-PsqlCommand -Label ([string]$query.Label) -SqlText ([string]$query.Sql)
        Write-Ok ([string]$query.Label)
    }
    Set-StepStatus -Step 'plano_execucao' -Status 'OK'

    $script:CurrentStep = 'crud'
    Show-Section -Title 'DEMO CRUD'
    Invoke-PsqlFile -SqlFile $requiredFiles['queries_crud']
    Write-Ok 'Script CRUD executado com rollback'
    Set-StepStatus -Step 'crud' -Status 'OK'

    $script:CurrentStep = 'conclusao'
    Set-StepStatus -Step 'resultado_final' -Status 'OK'
    Write-Ok 'Showcase concluido com sucesso'
}
catch {
    if (-not [string]::IsNullOrWhiteSpace($script:CurrentStep)) {
        Set-StepStatus -Step $script:CurrentStep -Status 'FAIL'
    }

        Set-StepStatus -Step 'resultado_final' -Status 'FAIL'
    $script:ExitCode = 1
    Write-Fail $_.Exception.Message
}
finally {
    if (($Mode -eq 'Docker') -and $Cleanup.IsPresent) {
        try {
            Stop-DockerDatabase
            Set-StepStatus -Step 'limpeza' -Status 'OK'
            Write-Ok 'Container removido'
        }
        catch {
            Set-StepStatus -Step 'limpeza' -Status 'FAIL'
            $script:ExitCode = 1
            Write-Fail "Falha na limpeza: $($_.Exception.Message)"
        }
    }
    elseif ($Mode -eq 'Docker') {
        Set-StepStatus -Step 'limpeza' -Status 'NAO EXECUTADA'
    }

    Restore-PasswordState
    Show-StepSummary
    $global:LASTEXITCODE = $script:ExitCode
}
