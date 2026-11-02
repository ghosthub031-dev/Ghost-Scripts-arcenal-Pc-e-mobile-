--=============================================================
--  👻 GHOST load (ARCENAL) V2.5.1 - PAINEL DE ESCOLHA (PC / MOBILE)
--  Nada roda antes do clique.
--  O jogador escolhe o modo -> SO ENTAO o loadstring executa.
--  Identidade visual do painel Ghost: preto + branco-cinza (sem azul)
--
--  V2.5.1 -> LETRA DO MOBILE IGUAL A DO PC:
--     * mesma familia de fonte nos dois modos (Gotham, sem fonte alternativa)
--     * TextScaled/RichText desligados (o celular nao estica nem troca a letra)
--     * emojis removidos so no celular: no Android eles caem numa fonte de
--       fallback e ficam feios/quadradinhos, quebrando o estilo do painel
--     * mesmo peso (Bold) e mesmo tamanho de fonte do PC
--=============================================================
local PHIL_UIS = game:GetService("UserInputService")
local PHIL_LP  = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")

--========================== LINKS ============================
local URL_PC     = "https://raw.githubusercontent.com/ghosthub031-dev/Ghost-Scripts-arcenal-Pc-e-mobile-/refs/heads/main/ghost_scripts_arsenal_pc.lua"
local URL_MOBILE = "https://raw.githubusercontent.com/ghosthub031-dev/Ghost-Scripts-arcenal-Pc-e-mobile-/refs/heads/main/ghost_scripts_arsenal_mobile.lua"

--=================== CONFIG DA LETRA NO CELULAR =============
-- false = letra limpa, identica a do PC (recomendado).
-- true  = mantem os emojis tambem no celular (pode ficar feio em alguns aparelhos).
local MANTER_EMOJI_NO_CELULAR = false

--======================= TEMA GHOST V2.5 ======================
local C = {
    BG       = Color3.fromRGB(22, 22, 28),    -- fundo do cartao
    BG_SOFT  = Color3.fromRGB(28, 28, 34),    -- fundo dos botoes
    ACCENT   = Color3.fromRGB(225, 225, 225), -- branco-cinza (destaque)
    ACCENT_D = Color3.fromRGB(180, 180, 180), -- cinza (destaque escuro)
    TEXT     = Color3.fromRGB(255, 255, 255),
    DIM      = Color3.fromRGB(140, 140, 148),
    STROKE   = Color3.fromRGB(72, 72, 84),
    WARN     = Color3.fromRGB(240, 120, 120),
    LOAD     = Color3.fromRGB(230, 200, 120),
}
local GHOST_ICON = "rbxassetid://139984424145579" -- mesma imagem do flutuante

--============= DETECCAO AUTOMATICA (SO VISUAL) ===============
-- Nao executa nada: apenas sugere e destaca o botao certo.
local modo_detectado = "pc"
if PHIL_UIS.TouchEnabled and not PHIL_UIS.KeyboardEnabled then
    modo_detectado = "mobile"
end

--================= TIPOGRAFIA UNICA (PC = MOBILE) ============
-- UMA familia de fonte para os dois modos. O celular usa exatamente a
-- mesma "letra" do PC: Gotham, mesmo peso e mesmo tamanho.
local FONTE = {
    TITULO = Enum.Font.GothamBlack,
    FORTE  = Enum.Font.GothamBold,
    MEDIA  = Enum.Font.GothamMedium,
    TEXTO  = Enum.Font.Gotham,
}

-- Aplica a letra padrao do painel em qualquer aparelho:
-- mesma fonte, tamanho fixo (sem TextScaled) e alinhamento do PC.
local function letraNormal(label, fonte, tamanho, cor, alinhamentoX)
    label.Font = fonte
    label.TextSize = tamanho
    if cor then label.TextColor3 = cor end
    label.TextScaled = false  -- o celular NAO aumenta/diminui a letra sozinho
    label.RichText = false    -- sem tags/<font> trocando a fonte no meio do texto
    -- sem contorno/sombra na letra: deixa a fonte limpa igual a do PC
    label.TextStrokeTransparency = 1
    if label:IsA("TextLabel") or label:IsA("TextButton") then
        pcall(function() label.TextStrokeColor3 = Color3.new(0, 0, 0) end)
    end
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextXAlignment = alinhamentoX or Enum.TextXAlignment.Center
    return label
end

-- Glifos: no PC mantem os emojis; no celular viram texto puro (letra limpa)
local EMOJI_OK = (modo_detectado ~= "mobile") or MANTER_EMOJI_NO_CELULAR
local function glifo(emoji)
    if EMOJI_OK then return emoji end
    return ""
end
local G_GHOST = glifo("👻 ")
local G_PC    = glifo("🖥️ ")
local G_MOB   = glifo("📱 ")
local G_LOAD  = glifo("⏳ ")
local G_ERR   = glifo("❌ ")

--========================= GUI BASE ==========================
local gui = Instance.new("ScreenGui")
gui.Name = "GhostLoad_Arsenal_V25"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 2000000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local okParent = false
pcall(function()
    local alvo = (gethui and gethui()) or game:GetService("CoreGui")
    gui.Parent = alvo
    okParent = gui.Parent ~= nil
end)
if not okParent then
    pcall(function() gui.Parent = PHIL_LP:WaitForChild("PlayerGui") end)
end

--====================== PAINEL CENTRAL =======================
local painel = Instance.new("Frame")
painel.Name = "Painel"
painel.AnchorPoint = Vector2.new(0.5, 0.5)
painel.Position = UDim2.fromScale(0.5, 0.5)
painel.Size = UDim2.fromOffset(440, 340)
painel.BackgroundColor3 = C.BG
painel.BackgroundTransparency = 0.04
painel.BorderSizePixel = 0
painel.Active = true
painel.Parent = gui

local pCorner = Instance.new("UICorner")
pCorner.CornerRadius = UDim.new(0, 18)
pCorner.Parent = painel

local pStroke = Instance.new("UIStroke")
pStroke.Color = C.ACCENT_D
pStroke.Thickness = 2
pStroke.Transparency = 0.35
pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border -- so a borda, nunca o texto
pStroke.Parent = painel

-- brilho suave de fundo (gradiente cinza, identidade V2.5)
local pGrad = Instance.new("UIGradient")
pGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 38)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 24)),
})
pGrad.Rotation = 90
pGrad.Parent = painel

-- escala para caber em telas de celular
-- (o UIScale reduz o painel inteiro no celular; a letra NAO e reescalada
--  por conta propria, por isso fica com o mesmo desenho do PC)
local escala = Instance.new("UIScale")
escala.Parent = painel
pcall(function()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
    escala.Scale = math.clamp(math.min(vp.X / 560, vp.Y / 470), 0.58, 1)
end)

--=============== ICONE FANTASMA (redondo, V2.5) ===============
local icone = Instance.new("ImageLabel")
icone.Name = "GhostIcon"
icone.Size = UDim2.fromOffset(72, 72)
icone.Position = UDim2.new(0.5, -36, 0, 18)
icone.BackgroundColor3 = C.BG_SOFT
icone.Image = GHOST_ICON
icone.ScaleType = Enum.ScaleType.Crop
icone.BorderSizePixel = 0
icone.Parent = painel
local iconeCorner = Instance.new("UICorner")
iconeCorner.CornerRadius = UDim.new(1, 0) -- redondo igual ao flutuante
iconeCorner.Parent = icone
local iconeStroke = Instance.new("UIStroke")
iconeStroke.Color = C.ACCENT
iconeStroke.Thickness = 2
iconeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border -- so a borda da imagem
iconeStroke.Parent = icone

--==================== TITULO / SUBTITULO =====================
local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 32)
titulo.Position = UDim2.fromOffset(0, 96)
titulo.BackgroundTransparency = 1
titulo.Text = G_GHOST .. "GHOST load (ARCENAL) V2.5"
letraNormal(titulo, FONTE.TITULO, 24, C.TEXT)
titulo.Parent = painel

local subtitulo = Instance.new("TextLabel")
subtitulo.Size = UDim2.new(1, -20, 0, 32)
subtitulo.Position = UDim2.fromOffset(10, 126)
subtitulo.BackgroundTransparency = 1
subtitulo.Text = "Escolha o seu dispositivo | Choose your device"
subtitulo.TextWrapped = true
letraNormal(subtitulo, FONTE.TEXTO, 14, C.DIM)
subtitulo.Parent = painel

--========================= BOTAO X ============================
local btnFechar = Instance.new("TextButton")
btnFechar.Name = "Fechar"
btnFechar.Size = UDim2.fromOffset(30, 30)
btnFechar.Position = UDim2.new(1, -38, 0, 8)
btnFechar.BackgroundColor3 = C.BG_SOFT
btnFechar.Text = "X"
btnFechar.AutoButtonColor = false
btnFechar.BorderSizePixel = 0
letraNormal(btnFechar, FONTE.FORTE, 14, C.TEXT)
btnFechar.Parent = painel
local fecharCorner = Instance.new("UICorner")
fecharCorner.CornerRadius = UDim.new(1, 0)
fecharCorner.Parent = btnFechar
btnFechar.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

--========================= BOTOES ============================
local function novoBotao(texto)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = C.BG_SOFT
    b.Text = texto
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    -- mesma letra do PC nos dois modos (GothamBold 16, centralizada)
    letraNormal(b, FONTE.FORTE, 16, C.TEXT)
    b.Parent = painel

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 14)
    c.Parent = b

    local s = Instance.new("UIStroke")
    s.Color = C.STROKE
    s.Thickness = 1.5
    s.Transparency = 0.4
    -- *** AQUI ERA O PROBLEMA ***
    -- Sem isto o contorno do botao tambem e desenhado em volta das LETRAS
    -- (modo Contextual), e a fonte fica gorda/borrada tipo adesivo.
    -- Border = contorno SO na moldura do botao; a letra fica limpa como no PC.
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = b

    return b, s
end

-- Botoes: emoji + nome do modo e a traducao (PT em cima, EN embaixo)
local txtPC     = G_PC .. "PC\nComputador | Computer"
local txtMobile = G_MOB .. "MOBILE\nCelular | Phone"

local btnPC, strokePC = novoBotao(txtPC)
btnPC.Size = UDim2.fromOffset(195, 96)
btnPC.Position = UDim2.fromOffset(16, 166)
btnPC.TextWrapped = true

local btnMobile, strokeMobile = novoBotao(txtMobile)
btnMobile.Size = UDim2.fromOffset(195, 96)
btnMobile.Position = UDim2.fromOffset(229, 166)
btnMobile.TextWrapped = true

-- feedback visual (hover/press) igual a V2.5
local function bindFeedback(btn)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(60, 60, 66) }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = C.BG_SOFT }):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), { Size = UDim2.fromOffset(185, 91) }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        if btn == btnPC then
            TweenService:Create(btn, TweenInfo.new(0.08), { Size = UDim2.fromOffset(195, 96) }):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.08), { Size = UDim2.fromOffset(195, 96) }):Play()
        end
    end)
end
bindFeedback(btnPC)
bindFeedback(btnMobile)

--=================== STATUS / DETECCAO =======================
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 40)
status.Position = UDim2.new(0, 20, 1, -78)
status.BackgroundTransparency = 1
status.TextWrapped = true
letraNormal(status, FONTE.MEDIA, 13, C.DIM, Enum.TextXAlignment.Left)
status.Parent = painel

-- destaque do modo detectado: contorno branco-cinza da V2.5
if modo_detectado == "mobile" then
    status.Text = G_MOB .. "Detectado: MOBILE (toque)\nDetected: MOBILE (touch) • recomendado"
    status.TextColor3 = C.ACCENT
    strokeMobile.Color = C.ACCENT
    strokeMobile.Transparency = 0
    strokeMobile.Thickness = 2.5
else
    status.Text = G_PC .. "Detectado: PC (teclado e mouse)\nDetected: PC (keyboard & mouse) • recomendado"
    status.TextColor3 = C.ACCENT
    strokePC.Color = C.ACCENT
    strokePC.Transparency = 0
    strokePC.Thickness = 2.5
end

--=================== BARRA DE CARREGAMENTO ====================
local barraBg = Instance.new("Frame")
barraBg.Name = "LoadBg"
barraBg.Size = UDim2.new(1, -40, 0, 10)
barraBg.Position = UDim2.new(0, 20, 1, -30)
barraBg.BackgroundColor3 = C.BG_SOFT
barraBg.BorderSizePixel = 0
barraBg.Visible = false
barraBg.Parent = painel
local barraBgCorner = Instance.new("UICorner")
barraBgCorner.CornerRadius = UDim.new(1, 0)
barraBgCorner.Parent = barraBg

local barraFill = Instance.new("Frame")
barraFill.Name = "LoadFill"
barraFill.Size = UDim2.new(0, 0, 1, 0)
barraFill.BackgroundColor3 = C.ACCENT
barraFill.BorderSizePixel = 0
barraFill.Parent = barraBg
local barraFillCorner = Instance.new("UICorner")
barraFillCorner.CornerRadius = UDim.new(1, 0)
barraFillCorner.Parent = barraFill

local function tweenBarra(frac, segundos)
    local t = TweenService:Create(barraFill, TweenInfo.new(segundos or 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(frac, 0, 1, 0)
    })
    t:Play()
    t.Completed:Wait()
end

--================= ARRASTAR O PAINEL (mobile e PC) ===========
do
    local arrastando, inicio, posInicial = false, nil, nil
    titulo.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
            arrastando = true
            inicio = input.Position
            posInicial = painel.Position
        end
    end)
    PHIL_UIS.InputChanged:Connect(function(input)
        if not arrastando then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseMovement then
            local d = input.Position - inicio
            painel.Position = UDim2.new(posInicial.X.Scale, posInicial.X.Offset + d.X,
                                        posInicial.Y.Scale, posInicial.Y.Offset + d.Y)
        end
    end)
    PHIL_UIS.InputEnded:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
            arrastando = false
        end
    end)
end

--=================== CARREGAR (SO NO CLIQUE) ==================
local executando = false

local function carregar(modo)
    if executando then return end
    executando = true

    local url = (modo == "mobile") and URL_MOBILE or URL_PC
    local botao = (modo == "mobile") and btnMobile or btnPC
    local txtOriginal = (modo == "mobile") and txtMobile or txtPC

    -- entra no modo carregando: esconde botoes, mostra barra (V2.5)
    btnPC.Visible = false
    btnMobile.Visible = false
    barraBg.Visible = true
    barraFill.Size = UDim2.new(0, 0, 1, 0)

    botao.Text = G_LOAD .. "CARREGANDO...\nLOADING..."
    status.TextColor3 = C.LOAD
    status.Text = "Preparando... | Preparing..."
    tweenBarra(0.3, 0.4)

    -- 1) baixa o script escolhido (nada executado ainda)
    status.Text = "Baixando script " .. string.upper(modo) .. "... | Downloading..."
    local fonte, erro
    local okDownload = pcall(function()
        fonte = game:HttpGet(url)
    end)
    tweenBarra(0.7, 0.4)

    if not okDownload or type(fonte) ~= "string" or #fonte < 20 then
        -- volta para a escolha em caso de erro (V2.5)
        barraBg.Visible = false
        btnPC.Visible = true
        btnMobile.Visible = true
        btnPC.Text = txtPC
        btnMobile.Text = txtMobile
        executando = false
        status.TextColor3 = C.WARN
        status.Text = G_ERR .. "Falha ao baixar o script\nDownload failed - check your internet and try again"
        warn("[Ghost Scripts] Falha no download: " .. tostring(fonte or erro))
        return
    end

    -- 2) valida antes de fechar o painel
    status.Text = "Injetando... | Injecting..."
    tweenBarra(0.95, 0.3)
    local chunk = loadstring(fonte)
    if not chunk then
        barraBg.Visible = false
        btnPC.Visible = true
        btnMobile.Visible = true
        btnPC.Text = txtPC
        btnMobile.Text = txtMobile
        btnPC.TextStrokeTransparency = 1
        btnMobile.TextStrokeTransparency = 1
        executando = false
        status.TextColor3 = C.WARN
        status.Text = G_ERR .. "Script invalido (executor sem loadstring?)\nInvalid script"
        warn("[Ghost Scripts] loadstring retornou nil")
        return
    end

    -- 3) sucesso: mostra 100%, fecha e SO AQUI executa o modo escolhido
    status.Text = "✔ Carregado! bom jogo 👻 | Loaded!"
    status.TextColor3 = C.ACCENT
    tweenBarra(1, 0.25)
    task.wait(0.4)
    gui:Destroy()

    local okRun, erroRun = pcall(chunk)
    if not okRun then
        warn("[Ghost Scripts] Erro ao executar (" .. modo .. "): " .. tostring(erroRun))
    end
end

btnPC.MouseButton1Click:Connect(function() carregar("pc") end)
btnMobile.MouseButton1Click:Connect(function() carregar("mobile") end)

print("[GhostLoad] 👻 GHOST load (ARCENAL) V2.5.1 pronto — versao sugerida: " .. string.upper(modo_detectado))
