Add-Type -AssemblyName System.Drawing

function Create-AmbientPhoto {
    param(
        [string]$Path,
        [System.Drawing.Color]$BgTop,
        [System.Drawing.Color]$BgBottom,
        [System.Drawing.Color]$AccentColor,
        [System.Drawing.Color]$SecondaryColor,
        [string]$VenueName,
        [string]$SceneType, # "Fachada & Entrada", "Barra Principal & Tragos", "Terraza & Mesas", "Pista, Música & Ambiente"
        [string]$VibeTag,
        [string]$VisualFeature # "neon_lasers", "wooden_taps", "sunset_terrace", "rock_stage", "cantina_tiles", "mezcal_lounge"
    )

    $Width = 1200
    $Height = 800

    $bmp = New-Object System.Drawing.Bitmap($Width, $Height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # 1. Fondo de Ambiente Nocturno
    $rect = New-Object System.Drawing.Rectangle(0, 0, $Width, $Height)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $BgTop, $BgBottom, [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal)
    $g.FillRectangle($bgBrush, $rect)
    $bgBrush.Dispose()

    # 2. Resplandores y Luces de Ambiente (Iluminación Cálida / Neón)
    $glowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(40, $AccentColor), 4)
    $glowBrush1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, $AccentColor))
    $glowBrush2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(25, $SecondaryColor))

    $g.FillEllipse($glowBrush1, [int]($Width * 0.1), [int]($Height * 0.1), [int]($Width * 0.4), [int]($Height * 0.6))
    $g.FillEllipse($glowBrush2, [int]($Width * 0.55), [int]($Height * 0.2), [int]($Width * 0.45), [int]($Height * 0.7))
    $glowBrush1.Dispose()
    $glowBrush2.Dispose()

    # 3. Elementos Gráficos Estilizados según Tipo de Escena
    if ($SceneType -like "*Fachada*") {
        # Silueta de Arquitectura / Entrada
        $archBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 10, 14, 24))
        $g.FillRectangle($archBrush, 0, [int]($Height * 0.55), $Width, [int]($Height * 0.45))
        $archBrush.Dispose()

        # Letrero Neón Iluminado en la Fachada
        $signPen = New-Object System.Drawing.Pen($AccentColor, 4)
        $signWidth = $Width - 300
        $signRect = New-Object System.Drawing.Rectangle(150, 160, $signWidth, 140)
        $g.DrawRectangle($signPen, $signRect)
        $signPen.Dispose()

        # Faroles / Guirnaldas de luces
        $lightPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, $SecondaryColor), 2)
        for ($x = 100; $x -lt $Width - 100; $x += 90) {
            $g.DrawEllipse($lightPen, $x, 110, 16, 16)
            $bulbBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, $SecondaryColor))
            $g.FillEllipse($bulbBrush, $x + 3, 113, 10, 10)
            $bulbBrush.Dispose()
        }
        $lightPen.Dispose()

    } elseif ($SceneType -like "*Barra*") {
        # Silueta de Barra y Botellas / Grifos de Cerveza
        $counterBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 12, 16, 26))
        $g.FillRectangle($counterBrush, 0, [int]($Height * 0.62), $Width, [int]($Height * 0.38))
        $counterBrush.Dispose()

        # Botellero Iluminado en Repisas
        $shelfPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, $AccentColor), 3)
        $g.DrawLine($shelfPen, 80, 240, $Width - 80, 240)
        $g.DrawLine($shelfPen, 80, 360, $Width - 80, 360)
        $shelfPen.Dispose()

        # Copas y Tarros iluminados
        $glassBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(140, $SecondaryColor))
        for ($bx = 120; $bx -lt $Width - 120; $bx += 65) {
            $g.FillRectangle($glassBrush, $bx, 200, 18, 38)
            $g.FillRectangle($glassBrush, $bx, 320, 22, 38)
        }
        $glassBrush.Dispose()

    } elseif ($SceneType -like "*Terraza*") {
        # Pergola de madera y cielo nocturno
        $pergolaPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 45, 30, 20), 8)
        for ($px = 50; $px -lt $Width; $px += 140) {
            $g.DrawLine($pergolaPen, $px, 50, $px + 100, 220)
        }
        $g.DrawLine($pergolaPen, 0, 180, $Width, 180)
        $pergolaPen.Dispose()

        # Luces colgantes Edison tipo Bistro
        $bistroBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 255, 200, 80))
        for ($bx = 90; $bx -lt $Width; $bx += 110) {
            $g.DrawLine([System.Drawing.Pens]::DarkSlateGray, $bx, 180, $bx, 240)
            $g.FillEllipse($bistroBrush, $bx - 8, 240, 16, 16)
        }
        $bistroBrush.Dispose()

        # Mesas y Vegetación
        $floorBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 15, 22, 32))
        $g.FillRectangle($floorBrush, 0, [int]($Height * 0.65), $Width, [int]($Height * 0.35))
        $floorBrush.Dispose()

    } else {
        # Pista de Baile / Escenario / Visuales Láser
        $laserPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, $AccentColor), 3)
        for ($i = 0; $i -le $Width; $i += 120) {
            $g.DrawLine($laserPen, [int]($Width / 2), 120, $i, $Height)
        }
        $laserPen.Dispose()

        $crowdBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 10, 10, 18))
        for ($cx = 0; $cx -lt $Width; $cx += 70) {
            $g.FillEllipse($crowdBrush, $cx, [int]($Height * 0.68), 90, 160)
        }
        $crowdBrush.Dispose()
    }

    # 4. Gradiente Degradado Inferior (Para Lectura Óptima en App)
    $scrimRect = New-Object System.Drawing.Rectangle(0, [int]($Height * 0.45), $Width, [int]($Height * 0.55))
    $scrimBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $scrimRect,
        [System.Drawing.Color]::FromArgb(0, 5, 8, 15),
        [System.Drawing.Color]::FromArgb(235, 5, 8, 15),
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
    )
    $g.FillRectangle($scrimBrush, $scrimRect)
    $scrimBrush.Dispose()

    # 5. Marco Neón Cyberpunk Sutil
    $framePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, $AccentColor), 3)
    $g.DrawRectangle($framePen, 15, 15, $Width - 30, $Height - 30)
    $framePen.Dispose()

    # 6. Tarjeta y Tipografía de Ambiente
    $fontBadge = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
    $fontTitle = New-Object System.Drawing.Font("Arial", 36, [System.Drawing.FontStyle]::Bold)
    $fontScene = New-Object System.Drawing.Font("Arial", 22, [System.Drawing.FontStyle]::Bold)
    $fontVibe = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Regular)

    $brushAccent = New-Object System.Drawing.SolidBrush($AccentColor)
    $brushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $brushSecondary = New-Object System.Drawing.SolidBrush($SecondaryColor)
    $brushMuted = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 220, 230, 240))

    # Badge de Ambiente Nocturno
    $badgeRect = New-Object System.Drawing.Rectangle(40, 40, 360, 44)
    $badgeBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 15, 23, 42))
    $g.FillRectangle($badgeBg, $badgeRect)
    $badgeBg.Dispose()
    $badgeBorder = New-Object System.Drawing.Pen($AccentColor, 2)
    $g.DrawRectangle($badgeBorder, $badgeRect)
    $badgeBorder.Dispose()

    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
    $sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString("FOTO DE AMBIENTE · COLIMA NIGHT", $fontBadge, $brushAccent, [System.Drawing.RectangleF]::new(40, 40, 360, 44), $sfCenter)

    # Textos de Ficha Técnica en la parte inferior
    $g.DrawString($VenueName.ToUpper(), $fontTitle, $brushWhite, 45, $Height - 210)
    $g.DrawString($SceneType, $fontScene, $brushSecondary, 48, $Height - 145)
    $g.DrawString($VibeTag, $fontVibe, $brushMuted, 48, $Height - 95)

    # Dispersar recursos tipográficos
    $fontBadge.Dispose()
    $fontTitle.Dispose()
    $fontScene.Dispose()
    $fontVibe.Dispose()
    $brushAccent.Dispose()
    $brushWhite.Dispose()
    $brushSecondary.Dispose()
    $brushMuted.Dispose()
    $glowPen.Dispose()

    # Guardar JPEG Ultra-Nítido
    $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.FormatDescription -eq 'JPEG' }
    $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 92L)
    $bmp.Save($Path, $encoder, $encParams)
    $encParams.Dispose()
    $bmp.Dispose()
    Write-Host "Created: $Path"
}

# Lista maestra de todos los 28 establecimientos con su identidad visual
$venues = @(
    @{
        Id = "bar_la_puerta"
        Name = "Bar La Puerta"
        BgTop = [System.Drawing.Color]::FromArgb(22, 6, 16)
        BgBottom = [System.Drawing.Color]::FromArgb(46, 10, 24)
        Accent = [System.Drawing.Color]::FromArgb(244, 63, 94) # Rose neon
        Secondary = [System.Drawing.Color]::FromArgb(250, 204, 21) # Amber
        Vibe = "Perreo Urbano, Reggaetón, Cervezas Frías y Ambiente Festivo en el Centro"
        Feature = "perreo"
    },
    @{
        Id = "cerveceria_chapultepec"
        Name = "Cervecería Chapultepec"
        BgTop = [System.Drawing.Color]::FromArgb(24, 16, 6)
        BgBottom = [System.Drawing.Color]::FromArgb(52, 34, 10)
        Accent = [System.Drawing.Color]::FromArgb(245, 158, 11) # Amber gold
        Secondary = [System.Drawing.Color]::FromArgb(239, 68, 68) # Red
        Vibe = "Todo a Un Mismo Precio: Tarros, Cócteles, Tacos y Sliders en Av. Carranza"
        Feature = "wooden_taps"
    },
    @{
        Id = "el_guachi"
        Name = "El Guachi & Rooftop"
        BgTop = [System.Drawing.Color]::FromArgb(20, 8, 32)
        BgBottom = [System.Drawing.Color]::FromArgb(54, 16, 68)
        Accent = [System.Drawing.Color]::FromArgb(255, 136, 0) # Sunset Orange
        Secondary = [System.Drawing.Color]::FromArgb(168, 85, 247) # Violet
        Vibe = "Sunset Sessions, Música Electrónica, Terraza Panorámica y Macro-Club"
        Feature = "sunset_terrace"
    },
    @{
        Id = "dos_puntos"
        Name = "Dos Puntos Cervecería"
        BgTop = [System.Drawing.Color]::FromArgb(8, 22, 20)
        BgBottom = [System.Drawing.Color]::FromArgb(14, 46, 38)
        Accent = [System.Drawing.Color]::FromArgb(45, 212, 191) # Teal
        Secondary = [System.Drawing.Color]::FromArgb(250, 204, 21) # Amber
        Vibe = "Cerveza Artesanal Local, Jardín al Aire Libre y Selección en Vinilo"
        Feature = "wooden_taps"
    },
    @{
        Id = "low_social_club"
        Name = "Low Social Club"
        BgTop = [System.Drawing.Color]::FromArgb(6, 6, 18)
        BgBottom = [System.Drawing.Color]::FromArgb(22, 12, 40)
        Accent = [System.Drawing.Color]::FromArgb(192, 132, 252) # Purple
        Secondary = [System.Drawing.Color]::FromArgb(56, 189, 248) # Cyan
        Vibe = "Underground Tech-House, Atmósfera Minimalista y Sistema de Audio Hi-Fi"
        Feature = "neon_lasers"
    },
    @{
        Id = "costa_carranza"
        Name = "Cervecería de la Costa Carranza"
        BgTop = [System.Drawing.Color]::FromArgb(8, 20, 26)
        BgBottom = [System.Drawing.Color]::FromArgb(16, 44, 48)
        Accent = [System.Drawing.Color]::FromArgb(45, 212, 191) # Teal
        Secondary = [System.Drawing.Color]::FromArgb(251, 191, 36) # Gold
        Vibe = "Craft Beer, Terraza Abierta, Pantalla Gigante para Deportes y Cocina Urbana"
        Feature = "wooden_taps"
    },
    @{
        Id = "costa_carranza_2"
        Name = "Costa Carranza Tasting & Lounge"
        BgTop = [System.Drawing.Color]::FromArgb(10, 22, 28)
        BgBottom = [System.Drawing.Color]::FromArgb(20, 48, 52)
        Accent = [System.Drawing.Color]::FromArgb(34, 211, 238) # Cyan
        Secondary = [System.Drawing.Color]::FromArgb(245, 158, 11) # Amber
        Vibe = "Salón Interior y Barra de Degustación con Cervezas de Temporada"
        Feature = "wooden_taps"
    },
    @{
        Id = "costa_tercer_anillo"
        Name = "Costa Tercer Anillo"
        BgTop = [System.Drawing.Color]::FromArgb(8, 18, 30)
        BgBottom = [System.Drawing.Color]::FromArgb(15, 38, 56)
        Accent = [System.Drawing.Color]::FromArgb(56, 189, 248) # Light Blue
        Secondary = [System.Drawing.Color]::FromArgb(250, 204, 21) # Amber
        Vibe = "Gran Taproom Metropolitano, Tanques de Acero y Terraza de Alta Afluencia"
        Feature = "wooden_taps"
    },
    @{
        Id = "costa_san_fernando"
        Name = "Costa San Fernando"
        BgTop = [System.Drawing.Color]::FromArgb(14, 18, 24)
        BgBottom = [System.Drawing.Color]::FromArgb(26, 36, 48)
        Accent = [System.Drawing.Color]::FromArgb(45, 212, 191)
        Secondary = [System.Drawing.Color]::FromArgb(251, 146, 60)
        Vibe = "Esquina Nocturna en Av. San Fernando, Cerveza de Barril y Precopeo Ágil"
        Feature = "wooden_taps"
    },
    @{
        Id = "costa_sandoval"
        Name = "Costa Ignacio Sandoval"
        BgTop = [System.Drawing.Color]::FromArgb(16, 20, 28)
        BgBottom = [System.Drawing.Color]::FromArgb(28, 40, 52)
        Accent = [System.Drawing.Color]::FromArgb(56, 189, 248)
        Secondary = [System.Drawing.Color]::FromArgb(250, 204, 21)
        Vibe = "Corredor Gastronómico Norte, Taps Frescos y Ambiente Relajado"
        Feature = "wooden_taps"
    },
    @{
        Id = "costa_pablo_silva"
        Name = "Costa Pablo Silva (VDA)"
        BgTop = [System.Drawing.Color]::FromArgb(12, 22, 26)
        BgBottom = [System.Drawing.Color]::FromArgb(24, 42, 46)
        Accent = [System.Drawing.Color]::FromArgb(45, 212, 191)
        Secondary = [System.Drawing.Color]::FromArgb(251, 191, 36)
        Vibe = "Corazón de Villa de Álvarez, Patio Cervecero y Piqueo al Carbón"
        Feature = "wooden_taps"
    },
    @{
        Id = "costa_la_paz"
        Name = "Costa Residencial La Paz"
        BgTop = [System.Drawing.Color]::FromArgb(14, 20, 26)
        BgBottom = [System.Drawing.Color]::FromArgb(26, 38, 48)
        Accent = [System.Drawing.Color]::FromArgb(45, 212, 191)
        Secondary = [System.Drawing.Color]::FromArgb(244, 63, 94)
        Vibe = "Barra de Barrio, Terraza Arbolada y Pints Artesanales de Colima"
        Feature = "wooden_taps"
    },
    @{
        Id = "costa_la_paz_2"
        Name = "Costa La Paz Jardín"
        BgTop = [System.Drawing.Color]::FromArgb(12, 24, 28)
        BgBottom = [System.Drawing.Color]::FromArgb(22, 46, 52)
        Accent = [System.Drawing.Color]::FromArgb(34, 211, 238)
        Secondary = [System.Drawing.Color]::FromArgb(251, 191, 36)
        Vibe = "Área de Jardín al Aire Libre con Pizzas a la Leña y Cerveza Helada"
        Feature = "wooden_taps"
    },
    @{
        Id = "costa_griselda_alvarez"
        Name = "Costa Griselda Álvarez"
        BgTop = [System.Drawing.Color]::FromArgb(10, 20, 26)
        BgBottom = [System.Drawing.Color]::FromArgb(22, 40, 48)
        Accent = [System.Drawing.Color]::FromArgb(45, 212, 191)
        Secondary = [System.Drawing.Color]::FromArgb(250, 204, 21)
        Vibe = "Taproom Amplio en Villa de Álvarez con Vista al Eje Urbano"
        Feature = "wooden_taps"
    },
    @{
        Id = "costa_santa_fe"
        Name = "Costa Santa Fe"
        BgTop = [System.Drawing.Color]::FromArgb(12, 18, 28)
        BgBottom = [System.Drawing.Color]::FromArgb(24, 38, 54)
        Accent = [System.Drawing.Color]::FromArgb(56, 189, 248)
        Secondary = [System.Drawing.Color]::FromArgb(244, 63, 94)
        Vibe = "Lounge Contemporáneo en el Norte, Coctelería de Lúpulo y Cenas Casuales"
        Feature = "wooden_taps"
    },
    @{
        Id = "colimita_centro"
        Name = "Cervecería de Colima (Centro)"
        BgTop = [System.Drawing.Color]::FromArgb(24, 18, 12)
        BgBottom = [System.Drawing.Color]::FromArgb(48, 32, 18)
        Accent = [System.Drawing.Color]::FromArgb(245, 158, 11) # Gold
        Secondary = [System.Drawing.Color]::FromArgb(251, 113, 133)
        Vibe = "Casa Colonial Histórica, Arcos de Cantera, Cerveza Colimita y Tradición"
        Feature = "cantina_tiles"
    },
    @{
        Id = "colimita_constitucion"
        Name = "Cervecería de Colima (Constitución)"
        BgTop = [System.Drawing.Color]::FromArgb(18, 16, 22)
        BgBottom = [System.Drawing.Color]::FromArgb(38, 30, 42)
        Accent = [System.Drawing.Color]::FromArgb(251, 191, 36)
        Secondary = [System.Drawing.Color]::FromArgb(168, 85, 247)
        Vibe = "Taproom Urbano Moderno sobre Av. Constitución con Flights de Cata"
        Feature = "wooden_taps"
    },
    @{
        Id = "dmt_rock_bar"
        Name = "DMT Rock Bar"
        BgTop = [System.Drawing.Color]::FromArgb(24, 8, 8)
        BgBottom = [System.Drawing.Color]::FromArgb(48, 14, 12)
        Accent = [System.Drawing.Color]::FromArgb(239, 68, 68) # Red
        Secondary = [System.Drawing.Color]::FromArgb(245, 158, 11) # Amber
        Vibe = "Rock Clásico, Grunge, Tarros de Cerveza y Guitarras en el Centro"
        Feature = "rock_stage"
    },
    @{
        Id = "foro_dmt"
        Name = "Foro DMT"
        BgTop = [System.Drawing.Color]::FromArgb(26, 10, 8)
        BgBottom = [System.Drawing.Color]::FromArgb(52, 18, 12)
        Accent = [System.Drawing.Color]::FromArgb(249, 115, 22) # Orange
        Secondary = [System.Drawing.Color]::FromArgb(239, 68, 68) # Red
        Vibe = "Escenario de Conciertos en Vivo, Tributos, Rock Indie y Festejo Nocturno"
        Feature = "rock_stage"
    },
    @{
        Id = "el_taurino"
        Name = "Cantina El Taurino"
        BgTop = [System.Drawing.Color]::FromArgb(22, 14, 8)
        BgBottom = [System.Drawing.Color]::FromArgb(46, 26, 12)
        Accent = [System.Drawing.Color]::FromArgb(245, 158, 11)
        Secondary = [System.Drawing.Color]::FromArgb(220, 38, 38)
        Vibe = "Cantina Tradicional Taurina, Cubetazos con Hielo y Botana al Minuto"
        Feature = "cantina_tiles"
    },
    @{
        Id = "mezcaleria_casa_colima"
        Name = "Mezcalería Casa Colima"
        BgTop = [System.Drawing.Color]::FromArgb(18, 12, 10)
        BgBottom = [System.Drawing.Color]::FromArgb(38, 22, 16)
        Accent = [System.Drawing.Color]::FromArgb(245, 158, 11)
        Secondary = [System.Drawing.Color]::FromArgb(244, 63, 94)
        Vibe = "Mezcales Artesanales, Copitas de Barro, Sales de Gusano y Terraza Íntima"
        Feature = "mezcal_lounge"
    },
    @{
        Id = "los_toros_barra_taurina"
        Name = "Los Toros Barra Taurina"
        BgTop = [System.Drawing.Color]::FromArgb(22, 12, 10)
        BgBottom = [System.Drawing.Color]::FromArgb(44, 22, 14)
        Accent = [System.Drawing.Color]::FromArgb(245, 158, 11)
        Secondary = [System.Drawing.Color]::FromArgb(239, 68, 68)
        Vibe = "Barra Botanera, Transmisiones Deportivas y Ambiente Folclórico"
        Feature = "cantina_tiles"
    },
    @{
        Id = "almada_cantina"
        Name = "Almada Cantina Fina"
        BgTop = [System.Drawing.Color]::FromArgb(10, 20, 16)
        BgBottom = [System.Drawing.Color]::FromArgb(20, 42, 34)
        Accent = [System.Drawing.Color]::FromArgb(16, 185, 129) # Emerald
        Secondary = [System.Drawing.Color]::FromArgb(245, 158, 11) # Gold
        Vibe = "Cantina Contemporánea de Alto Nivel, Mixología Mexicana y Botana Gourmet"
        Feature = "cantina_tiles"
    },
    @{
        Id = "el_gustito"
        Name = "El Gustito Botanero"
        BgTop = [System.Drawing.Color]::FromArgb(20, 14, 10)
        BgBottom = [System.Drawing.Color]::FromArgb(42, 26, 16)
        Accent = [System.Drawing.Color]::FromArgb(251, 146, 60)
        Secondary = [System.Drawing.Color]::FromArgb(250, 204, 21)
        Vibe = "Patio Familiar y de Amigos, Micheladas Gigantes y Mariscos al Centro"
        Feature = "cantina_tiles"
    },
    @{
        Id = "la_regional"
        Name = "La Regional Botanero"
        BgTop = [System.Drawing.Color]::FromArgb(22, 16, 8)
        BgBottom = [System.Drawing.Color]::FromArgb(44, 30, 12)
        Accent = [System.Drawing.Color]::FromArgb(245, 158, 11)
        Secondary = [System.Drawing.Color]::FromArgb(239, 68, 68)
        Vibe = "Cultura Cantinera Viva sobre Sevilla del Río, Charolas de Botana y Ronda de Tragos"
        Feature = "cantina_tiles"
    },
    @{
        Id = "la_chintola"
        Name = "La Chintola Botanero"
        BgTop = [System.Drawing.Color]::FromArgb(12, 20, 22)
        BgBottom = [System.Drawing.Color]::FromArgb(24, 40, 44)
        Accent = [System.Drawing.Color]::FromArgb(45, 212, 191)
        Secondary = [System.Drawing.Color]::FromArgb(251, 191, 36)
        Vibe = "Palapa Tropical sobre Blvd. Camino Real, Tostadas de Ceviche y Caguamas Frías"
        Feature = "cantina_tiles"
    },
    @{
        Id = "santo_mezcal"
        Name = "Santo Mezcal"
        BgTop = [System.Drawing.Color]::FromArgb(18, 10, 24)
        BgBottom = [System.Drawing.Color]::FromArgb(40, 18, 52)
        Accent = [System.Drawing.Color]::FromArgb(192, 132, 252)
        Secondary = [System.Drawing.Color]::FromArgb(245, 158, 11)
        Vibe = "Templo Mezcalero, Iluminación Mística de Velas y Cócteles Botánicos de Autor"
        Feature = "mezcal_lounge"
    },
    @{
        Id = "paraiso_drinks"
        Name = "Paraíso Drinks"
        BgTop = [System.Drawing.Color]::FromArgb(22, 8, 22)
        BgBottom = [System.Drawing.Color]::FromArgb(48, 14, 44)
        Accent = [System.Drawing.Color]::FromArgb(236, 72, 153) # Neon Pink
        Secondary = [System.Drawing.Color]::FromArgb(34, 211, 238) # Cyan
        Vibe = "Coctelería Neón de Autor, Pop Latino, Precopeo Cosmopolita y Letreros LED"
        Feature = "neon_lasers"
    }
)

foreach ($v in $venues) {
    $id = $v.Id

    # 1. Foto de Portada (Fachada / Exterior)
    Create-AmbientPhoto `
        -Path "assets/images/venues/$id.jpg" `
        -BgTop $v.BgTop -BgBottom $v.BgBottom -AccentColor $v.Accent -SecondaryColor $v.Secondary `
        -VenueName $v.Name `
        -SceneType "Fachada & Entrada Nocturna" `
        -VibeTag $v.Vibe `
        -VisualFeature $v.Feature

    # 2. Foto de Galería 1 (Barra Principal)
    Create-AmbientPhoto `
        -Path "assets/images/venues/${id}_2.jpg" `
        -BgTop $v.BgTop -BgBottom $v.BgBottom -AccentColor $v.Accent -SecondaryColor $v.Secondary `
        -VenueName $v.Name `
        -SceneType "Barra Principal & Coctelería" `
        -VibeTag "Servicio ágil de barra, tragos de autor y tarros fríos" `
        -VisualFeature $v.Feature

    # 3. Foto de Galería 2 (Terraza / Mesas)
    Create-AmbientPhoto `
        -Path "assets/images/venues/${id}_3.jpg" `
        -BgTop $v.BgTop -BgBottom $v.BgBottom -AccentColor $v.Accent -SecondaryColor $v.Secondary `
        -VenueName $v.Name `
        -SceneType "Terraza, Mesas & Confort" `
        -VibeTag "Mesas al aire libre, iluminación tenue y áreas lounge" `
        -VisualFeature $v.Feature

    # 4. Foto de Galería 3 (Pista / Música / Escenario)
    Create-AmbientPhoto `
        -Path "assets/images/venues/${id}_4.jpg" `
        -BgTop $v.BgTop -BgBottom $v.BgBottom -AccentColor $v.Accent -SecondaryColor $v.Secondary `
        -VenueName $v.Name `
        -SceneType "Pista, Iluminación & Música en Vivo" `
        -VibeTag "Sets en vivo, audio de alta fidelidad y noche vibrante" `
        -VisualFeature $v.Feature

    # Si es bar_la_puerta, también asegurar compatibilidad con la_puerta_bar
    if ($id -eq "bar_la_puerta") {
        Copy-Item "assets/images/venues/$id.jpg" "assets/images/venues/la_puerta_bar.jpg" -Force
        Copy-Item "assets/images/venues/${id}_2.jpg" "assets/images/venues/la_puerta_bar_2.jpg" -Force
        Copy-Item "assets/images/venues/${id}_3.jpg" "assets/images/venues/la_puerta_bar_3.jpg" -Force
        Copy-Item "assets/images/venues/${id}_4.jpg" "assets/images/venues/la_puerta_bar_4.jpg" -Force
    }
}

Write-Host "Todas las fotos de ambiente generadas exitosamente para los 28 establecimientos!"
