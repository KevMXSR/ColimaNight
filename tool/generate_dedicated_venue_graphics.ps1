Add-Type -AssemblyName System.Drawing

function Create-Flyer916 {
    param(
        [hashtable]$P
    )

    $Width = 1080
    $Height = 1920

    $bmp = New-Object System.Drawing.Bitmap($Width, $Height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # 1. Background Gradient (Atmospheric Deep Nightlife)
    $rect = New-Object System.Drawing.Rectangle(0, 0, $Width, $Height)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $P.BgTop, $P.BgBottom, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
    $g.FillRectangle($bgBrush, $rect)
    $bgBrush.Dispose()

    # 2. Authentic Nightlife / Cyber Patterns
    $patternPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(45, $P.AccentColor), 2)
    $style = $P.StylePattern
    if ($style -eq 'lasers') {
        for ($i = 0; $i -le $Width; $i += 100) {
            $g.DrawLine($patternPen, [int]($Width / 2), 200, $i, $Height)
        }
        for ($y = 600; $y -le $Height; $y += 120) {
            $g.DrawLine($patternPen, 0, $y, $Width, $y)
        }
    } elseif ($style -eq 'sunset') {
        $sunsetBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, $P.AccentColor))
        $g.FillEllipse($sunsetBrush, -150, 100, 1380, 1000)
        $sunsetBrush.Dispose()
        for ($r = 250; $r -le 950; $r += 140) {
            $g.DrawEllipse($patternPen, [int](($Width / 2) - $r), [int](600 - $r), [int]($r * 2), [int]($r * 2))
        }
    } elseif ($style -eq 'grunge') {
        for ($x = -400; $x -le $Width + 400; $x += 160) {
            $g.DrawLine($patternPen, $x, 0, $x + 600, $Height)
        }
    } elseif ($style -eq 'perreo') {
        for ($y = 250; $y -lt $Height; $y += 180) {
            $g.DrawBezier($patternPen, 0, $y, [int]($Width * 0.35), $y - 100, [int]($Width * 0.65), $y + 100, $Width, $y)
        }
        $glowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, $P.AccentColor))
        $g.FillEllipse($glowBrush, 100, 400, 880, 880)
        $glowBrush.Dispose()
    } elseif ($style -eq 'sports') {
        for ($i = 0; $i -le $Width; $i += 180) {
            $g.DrawLine($patternPen, 0, 0, $i, $Height)
            $g.DrawLine($patternPen, $Width, 0, $i, $Height)
        }
    } else {
        for ($x = 60; $x -lt $Width; $x += 180) {
            for ($y = 200; $y -lt $Height; $y += 240) {
                $g.DrawRectangle($patternPen, $x, $y, 120, 120)
            }
        }
    }
    $patternPen.Dispose()

    # 3. Outer Glowing Frame (9:16 Story Border)
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, $P.AccentColor), 8)
    $g.DrawRectangle($borderPen, 40, 40, $Width - 80, $Height - 80)
    $borderPen.Dispose()

    $innerBorderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, $P.SecondaryColor), 2)
    $g.DrawRectangle($innerBorderPen, 55, 55, $Width - 110, $Height - 110)
    $innerBorderPen.Dispose()

    # 4. Top Header Badge
    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
    $sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

    $topPillRect = New-Object System.Drawing.Rectangle(80, 90, 440, 65)
    $topPillBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 15, 23, 42))
    $g.FillRectangle($topPillBg, $topPillRect)
    $topPillBg.Dispose()

    $topPillBorder = New-Object System.Drawing.Pen($P.AccentColor, 3)
    $g.DrawRectangle($topPillBorder, $topPillRect)
    $topPillBorder.Dispose()

    $fontBadge = New-Object System.Drawing.Font("Arial", 18, [System.Drawing.FontStyle]::Bold)
    $brushBadge = New-Object System.Drawing.SolidBrush($P.AccentColor)
    $g.DrawString($P.CategoryBadge.ToUpper(), $fontBadge, $brushBadge, [System.Drawing.RectangleF]::new(80, 90, 440, 65), $sfCenter)
    $fontBadge.Dispose()
    $brushBadge.Dispose()

    # 5. Venue Title Header
    $fontVenue = New-Object System.Drawing.Font("Arial", 46, [System.Drawing.FontStyle]::Bold)
    $brushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.DrawString($P.VenueTitle, $fontVenue, $brushWhite, [System.Drawing.RectangleF]::new(80, 190, $Width - 160, 110))
    $fontVenue.Dispose()

    # Accent underline
    $linePen = New-Object System.Drawing.Pen($P.AccentColor, 8)
    $g.DrawLine($linePen, 80, 310, 480, 310)
    $linePen.Dispose()

    # 6. Event Main Headline
    $fontHeadline = New-Object System.Drawing.Font("Arial", 54, [System.Drawing.FontStyle]::Bold)
    $brushAccent = New-Object System.Drawing.SolidBrush($P.AccentColor)
    $g.DrawString($P.EventHeadline, $fontHeadline, $brushAccent, [System.Drawing.RectangleF]::new(80, 350, $Width - 160, 300))
    $fontHeadline.Dispose()
    $brushAccent.Dispose()

    # 7. Subheadline / Description (Multi-line comfortable layout)
    $fontSub = New-Object System.Drawing.Font("Arial", 30, [System.Drawing.FontStyle]::Regular)
    $brushMuted = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 241, 245, 249))
    $g.DrawString($P.EventSubheadline, $fontSub, $brushMuted, [System.Drawing.RectangleF]::new(80, 680, $Width - 160, 280))
    $fontSub.Dispose()
    $brushMuted.Dispose()

    # 8. Date & Time Box
    $boxW = [int]($Width - 160)
    $dateBox = New-Object System.Drawing.Rectangle(80, 1000, $boxW, 140)
    $dateBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(210, 15, 23, 42))
    $g.FillRectangle($dateBg, $dateBox)
    $dateBg.Dispose()

    $dateBorder = New-Object System.Drawing.Pen($P.SecondaryColor, 3)
    $g.DrawRectangle($dateBorder, $dateBox)
    $dateBorder.Dispose()

    $fontDate = New-Object System.Drawing.Font("Arial", 32, [System.Drawing.FontStyle]::Bold)
    $brushSec = New-Object System.Drawing.SolidBrush($P.SecondaryColor)
    $dateTextW = [float]($Width - 220)
    $g.DrawString($P.DateString, $fontDate, $brushSec, [System.Drawing.RectangleF]::new(110, 1045, $dateTextW, 60))
    $fontDate.Dispose()
    $brushSec.Dispose()

    # 9. Location Line
    if ($P.LocationString) {
        $fontLoc = New-Object System.Drawing.Font("Arial", 24, [System.Drawing.FontStyle]::Bold)
        $brushLoc = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 255, 255, 255))
        $locText = "UBICACION: " + $P.LocationString
        $g.DrawString($locText, $fontLoc, $brushLoc, [System.Drawing.RectangleF]::new(80, 1170, [float]$boxW, 60))
        $fontLoc.Dispose()
        $brushLoc.Dispose()
    }

    # 10. Promo Tag Box
    if ($P.PromoTag) {
        $promoRect = New-Object System.Drawing.Rectangle(80, 1260, $boxW, 115)
        $promoBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, $P.AccentColor.R, $P.AccentColor.G, $P.AccentColor.B))
        $g.FillRectangle($promoBg, $promoRect)
        $promoBg.Dispose()

        $fontPromo = New-Object System.Drawing.Font("Arial", 28, [System.Drawing.FontStyle]::Bold)
        $brushDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))
        $g.DrawString($P.PromoTag, $fontPromo, $brushDark, [System.Drawing.RectangleF]::new(80, 1260, [float]$boxW, 115), $sfCenter)
        $fontPromo.Dispose()
        $brushDark.Dispose()
    }

    # 11. Presale Tag Box
    if ($P.PresaleTag) {
        $presaleRect = New-Object System.Drawing.Rectangle(80, 1400, $boxW, 115)
        $presaleBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 16, 185, 129))
        $g.FillRectangle($presaleBg, $presaleRect)
        $presaleBg.Dispose()

        $fontPresale = New-Object System.Drawing.Font("Arial", 28, [System.Drawing.FontStyle]::Bold)
        $brushWhiteP = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
        $g.DrawString($P.PresaleTag, $fontPresale, $brushWhiteP, [System.Drawing.RectangleF]::new(80, 1400, [float]$boxW, 115), $sfCenter)
        $fontPresale.Dispose()
        $brushWhiteP.Dispose()
    }

    # 12. Bottom Social Footer
    $socialFooterRect = New-Object System.Drawing.Rectangle(80, 1720, $boxW, 110)
    $socialFooterBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(210, 15, 23, 42))
    $g.FillRectangle($socialFooterBg, $socialFooterRect)
    $socialFooterBg.Dispose()

    $socialFooterBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 255, 255, 255), 1.5)
    $g.DrawRectangle($socialFooterBorder, $socialFooterRect)
    $socialFooterBorder.Dispose()

    $socialText = "IG: " + $P.InstagramHandle
    if ($P.FacebookHandle) {
        $socialText = $socialText + "  |  FB: " + $P.FacebookHandle
    }
    $socialText = $socialText + "  |  COLIMA NIGHT"

    $fontIg = New-Object System.Drawing.Font("Arial", 22, [System.Drawing.FontStyle]::Bold)
    $brushIg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.DrawString($socialText, $fontIg, $brushIg, [System.Drawing.RectangleF]::new(80, 1720, [float]$boxW, 110), $sfCenter)
    $fontIg.Dispose()
    $brushIg.Dispose()

    $sfCenter.Dispose()
    $brushWhite.Dispose()
    $g.Dispose()

    # Save as ultra-crisp JPEG
    $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.FormatDescription -eq 'JPEG' }
    $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 95L)
    $bmp.Save($P.Path, $encoder, $encParams)
    $encParams.Dispose()
    $bmp.Dispose()
    Write-Host "Created 9:16 flyer: $($P.Path)"
}

# 1. Bar La Puerta - Perreo Bellako (@lapuertadelperreo.dog)
Create-Flyer916 @{
    Path = "assets/images/venues/flyers/la_puerta_del_perreo_flyer.jpg"
    BgTop = [System.Drawing.Color]::FromArgb(20, 5, 15)
    BgBottom = [System.Drawing.Color]::FromArgb(48, 10, 26)
    AccentColor = [System.Drawing.Color]::FromArgb(244, 63, 94)
    SecondaryColor = [System.Drawing.Color]::FromArgb(250, 204, 21)
    CategoryBadge = "Perreo Underground"
    VenueTitle = "BAR LA PUERTA"
    EventHeadline = "NOCHE BELLAKA - LA PUERTA DEL PERREO"
    EventSubheadline = "DJs urbanos en vivo, perreo old school, bellakeo intenso, shots de cortesia y caguamas bien frias en el corazon de Colima."
    DateString = "VIERNES Y SABADO - 9:00 PM A 4:00 AM"
    LocationString = "C. 27 de Septiembre 135, Centro de Colima"
    PromoTag = "SIN COVER ANTES DE 11 PM - SHOTS DE BIENVENIDA"
    InstagramHandle = "@lapuertadelperreo.dog"
    FacebookHandle = "Bar La Puerta Colima"
    StylePattern = "perreo"
}

# 2. Bar La Puerta - Jueves Snacks & Drinks (@barlapuerta)
Create-Flyer916 @{
    Path = "assets/images/venues/flyers/bar_la_puerta_flyer.jpg"
    BgTop = [System.Drawing.Color]::FromArgb(22, 10, 16)
    BgBottom = [System.Drawing.Color]::FromArgb(52, 14, 28)
    AccentColor = [System.Drawing.Color]::FromArgb(251, 113, 133)
    SecondaryColor = [System.Drawing.Color]::FromArgb(251, 191, 36)
    CategoryBadge = "Bar Urbano y Snacks"
    VenueTitle = "BAR LA PUERTA"
    EventHeadline = "JUEVES DE SNACKS Y DRINKS"
    EventSubheadline = "Apertura especial a las 7:00 PM con botanas preparadas, alitas, micheladas y musica urbana para arrancar el fin de semana."
    DateString = "TODOS LOS JUEVES - 7:00 PM A 3:00 AM"
    LocationString = "C. 27 de Septiembre 135, Centro de Colima"
    PromoTag = "2X1 EN BEBIDAS SELECCIONADAS Y SNACKS"
    InstagramHandle = "@barlapuerta"
    FacebookHandle = "Bar La Puerta Colima"
    StylePattern = "perreo"
}

# 3. Costa Carranza - Transmisión de Fútbol en Pantalla Gigante (@costacarranza)
Create-Flyer916 @{
    Path = "assets/images/venues/flyers/costa_carranza_futbol_flyer.jpg"
    BgTop = [System.Drawing.Color]::FromArgb(8, 20, 24)
    BgBottom = [System.Drawing.Color]::FromArgb(15, 42, 45)
    AccentColor = [System.Drawing.Color]::FromArgb(45, 212, 191)
    SecondaryColor = [System.Drawing.Color]::FromArgb(250, 204, 21)
    CategoryBadge = "Transmision en Vivo"
    VenueTitle = "COSTA CARRANZA"
    EventHeadline = "FUTBOL EN PANTALLA GIGANTE Y CUBETAZO"
    EventSubheadline = "Vive la emocion de la Liga MX y partidos estelares con audio en vivo, pantalla gigante en terraza al aire libre y cerveza fria."
    DateString = "FINES DE SEMANA - DESDE LAS 5:00 PM"
    LocationString = "Av. Venustiano Carranza 110, Colima"
    PromoTag = "CUBETAZO ARTESANAL Y 2X1 EN BOTANAS"
    InstagramHandle = "@costacarranza"
    FacebookHandle = "Costa Carranza Colima"
    StylePattern = "sports"
}

# 4. Foro DMT - Concierto en Vivo & Preventa (@foro_dmt)
Create-Flyer916 @{
    Path = "assets/images/venues/flyers/foro_dmt_rock_flyer.jpg"
    BgTop = [System.Drawing.Color]::FromArgb(24, 12, 8)
    BgBottom = [System.Drawing.Color]::FromArgb(48, 18, 10)
    AccentColor = [System.Drawing.Color]::FromArgb(249, 115, 22)
    SecondaryColor = [System.Drawing.Color]::FromArgb(239, 68, 68)
    CategoryBadge = "Rock en Vivo"
    VenueTitle = "FORO DMT"
    EventHeadline = "NOCHE DE ROCK EN VIVO Y TRIBUTOS"
    EventSubheadline = "Bandas locales invitadas con tributos a Caifanes, Soda Stereo, grunge independiente y cerveza artesanal fria."
    DateString = "VIERNES Y SABADO - 9:30 PM A 3:00 AM"
    LocationString = "C. Santos Degollado 50, Centro de Colima"
    PromoTag = "ENTRADA LIBRE ANTES DE 10 PM"
    PresaleTag = "PREVENTA: $120 MXN - TAQUILLA: $180 MXN"
    InstagramHandle = "@foro_dmt"
    FacebookHandle = "Foro DMT Rock Bar"
    StylePattern = "grunge"
}

# 5. Dos Puntos - Craft Beer & Vinyl Taproom (@dospuntoscerveceria)
Create-Flyer916 @{
    Path = "assets/images/venues/flyers/dos_puntos_flyer.jpg"
    BgTop = [System.Drawing.Color]::FromArgb(8, 24, 22)
    BgBottom = [System.Drawing.Color]::FromArgb(14, 46, 38)
    AccentColor = [System.Drawing.Color]::FromArgb(45, 212, 191)
    SecondaryColor = [System.Drawing.Color]::FromArgb(250, 204, 21)
    CategoryBadge = "Taproom y Jardin"
    VenueTitle = "DOS PUNTOS"
    EventHeadline = "CRAFT BEER Y INDIE NIGHTS"
    EventSubheadline = "Cerveza artesanal local en barril, jardin cervecero al aire libre, seleccion en vinilo, hamburguesas smash y ambiente relajado."
    DateString = "MIERCOLES A SABADO - 6:00 PM A 1:00 AM"
    LocationString = "Tercer Anillo Periferico, Colima"
    PromoTag = "2X1 EN PINTS SELECCIONADAS (7 A 9 PM)"
    InstagramHandle = "@dospuntoscerveceria"
    FacebookHandle = "Dos Puntos Taproom"
    StylePattern = "taproom"
}

# 6. Guachi Rooftop - Sunset Electronic Sessions (@guachirooftop)
Create-Flyer916 @{
    Path = "assets/images/venues/flyers/guachi_rooftop_flyer.jpg"
    BgTop = [System.Drawing.Color]::FromArgb(18, 8, 30)
    BgBottom = [System.Drawing.Color]::FromArgb(55, 18, 70)
    AccentColor = [System.Drawing.Color]::FromArgb(255, 140, 0)
    SecondaryColor = [System.Drawing.Color]::FromArgb(168, 85, 247)
    CategoryBadge = "Rooftop y Terraza"
    VenueTitle = "GUACHI ROOFTOP"
    EventHeadline = "SUNSET ELECTRONIC SESSIONS"
    EventSubheadline = "Tech-House y Deep Sunset con mixologia de autor, vista panoramica al volcan y alineacion de DJs invitados de musica electronica."
    DateString = "VIERNES Y SABADO - 6:00 PM EN ADELANTE"
    LocationString = "Tercer Anillo Periferico, Colima"
    PromoTag = "2X1 EN COCTELERIA DE AUTOR ANTES DE 9 PM"
    InstagramHandle = "@guachirooftop"
    FacebookHandle = "El Guachi Colima"
    StylePattern = "sunset"
}

# 7. Low Social Club - Underground Tech-House (@lowclub.col)
Create-Flyer916 @{
    Path = "assets/images/venues/flyers/low_social_flyer.jpg"
    BgTop = [System.Drawing.Color]::FromArgb(6, 6, 18)
    BgBottom = [System.Drawing.Color]::FromArgb(22, 12, 40)
    AccentColor = [System.Drawing.Color]::FromArgb(192, 132, 252)
    SecondaryColor = [System.Drawing.Color]::FromArgb(56, 189, 248)
    CategoryBadge = "Club Electronico"
    VenueTitle = "LOW SOCIAL CLUB"
    EventHeadline = "UNDERGROUND TECH Y AFRO HOUSE"
    EventSubheadline = "Club nocturno con atmosfera minimalista, sistema de sonido de alta fidelidad, visuales envolventes y DJs residentes."
    DateString = "JUEVES A SABADO - 10:00 PM A 5:00 AM"
    LocationString = "Calle Miguel Hidalgo 165, Centro de Colima"
    PromoTag = "2X1 EN MIXOLOGIA ANTES DE MEDIANOCHE"
    PresaleTag = "ACCESO PREVENTA: $100 MXN (INCLUYE DRINK)"
    InstagramHandle = "@lowclub.col"
    FacebookHandle = "Low Social Club"
    StylePattern = "lasers"
}

# 8. Cervecería Chapultepec - Todo a un Mismo Precio (@cerveceriachapultepeccolima)
Create-Flyer916 @{
    Path = "assets/images/venues/flyers/cerveceria_chapultepec_flyer.jpg"
    BgTop = [System.Drawing.Color]::FromArgb(24, 18, 6)
    BgBottom = [System.Drawing.Color]::FromArgb(54, 38, 12)
    AccentColor = [System.Drawing.Color]::FromArgb(245, 158, 11)
    SecondaryColor = [System.Drawing.Color]::FromArgb(239, 68, 68)
    CategoryBadge = "Cerveceria Casual"
    VenueTitle = "CERVECERIA CHAPULTEPEC"
    EventHeadline = "TODO A UN MISMO PRECIO"
    EventSubheadline = "Tarros de cerveza helada, cocteleria, tacos, hamburguesas, sliders y botanas completas a precio unico accesible todos los dias."
    DateString = "LUNES A DOMINGO - 1:00 PM A 1:00 AM (VIE Y SAB HASTA 2:00 AM)"
    LocationString = "Av. Venustiano Carranza #1726, Esmeralda Nte., Colima"
    PromoTag = "TODO A UN MISMO PRECIO - ENTRADA LIBRE"
    InstagramHandle = "@cerveceriachapultepeccolima"
    FacebookHandle = "Cerveceria Chapultepec Colima"
    StylePattern = "taproom"
}
