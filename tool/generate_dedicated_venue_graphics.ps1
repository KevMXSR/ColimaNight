Add-Type -AssemblyName System.Drawing

function Create-Flyer {
    param(
        [string]$Path,
        [int]$Width = 1080,
        [int]$Height = 1350,
        [System.Drawing.Color]$BgTop,
        [System.Drawing.Color]$BgBottom,
        [System.Drawing.Color]$AccentColor,
        [System.Drawing.Color]$SecondaryColor,
        [string]$CategoryBadge,
        [string]$VenueTitle,
        [string]$EventHeadline,
        [string]$EventSubheadline,
        [string]$DateString,
        [string]$PromoTag,
        [string]$InstagramHandle,
        [string]$StylePattern
    )

    $bmp = New-Object System.Drawing.Bitmap($Width, $Height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # 1. Background Gradient
    $rect = New-Object System.Drawing.Rectangle(0, 0, $Width, $Height)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $BgTop, $BgBottom, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
    $g.FillRectangle($bgBrush, $rect)
    $bgBrush.Dispose()

    # 2. Geometric Cyber / Nightlife Patterns
    $patternPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(40, $AccentColor), 2)
    if ($StylePattern -eq 'lasers') {
        for ($i = 0; $i -le $Width; $i += 120) {
            $g.DrawLine($patternPen, [int]($Width / 2), 0, $i, $Height)
        }
        for ($y = 400; $y -le $Height; $y += 90) {
            $g.DrawLine($patternPen, 0, $y, $Width, $y)
        }
    } elseif ($StylePattern -eq 'sunset') {
        # Concentric glowing circles
        $sunsetBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, $AccentColor))
        $g.FillEllipse($sunsetBrush, -200, -100, 1480, 800)
        $sunsetBrush.Dispose()
        for ($r = 200; $r -le 700; $r += 100) {
            $g.DrawEllipse($patternPen, ($Width / 2) - $r, 350 - $r, $r * 2, $r * 2)
        }
    } elseif ($StylePattern -eq 'grunge') {
        # Rock angular diagonal slashes
        for ($x = -200; $x -le $Width + 200; $x += 140) {
            $g.DrawLine($patternPen, $x, 0, $x + 400, $Height)
        }
    } elseif ($StylePattern -eq 'taproom') {
        # Craft hops / minimalist geometric squares
        for ($x = 60; $x -lt $Width; $x += 160) {
            for ($y = 100; $y -lt $Height; $y += 180) {
                $g.DrawRectangle($patternPen, $x, $y, 100, 100)
            }
        }
    } else {
        # Urban neon waves
        for ($y = 200; $y -lt $Height; $y += 150) {
            $g.DrawBezier($patternPen, 0, $y, [int]($Width * 0.3), $y - 60, [int]($Width * 0.7), $y + 60, $Width, $y)
        }
    }
    $patternPen.Dispose()

    # 3. Outer Glowing Cyber Frame
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, $AccentColor), 6)
    $g.DrawRectangle($borderPen, 35, 35, $Width - 70, $Height - 70)
    $borderPen.Dispose()

    $innerBorderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, $SecondaryColor), 2)
    $g.DrawRectangle($innerBorderPen, 50, 50, $Width - 100, $Height - 100)
    $innerBorderPen.Dispose()

    # 4. Top Category Pill Badge
    $badgeRect = New-Object System.Drawing.Rectangle(80, 80, 360, 60)
    $badgeBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(210, 15, 23, 42))
    $g.FillRectangle($badgeBg, $badgeRect)
    $badgeBg.Dispose()

    $badgeBorder = New-Object System.Drawing.Pen($AccentColor, 3)
    $g.DrawRectangle($badgeBorder, $badgeRect)
    $badgeBorder.Dispose()

    $fontBadge = New-Object System.Drawing.Font("Arial", 18, [System.Drawing.FontStyle]::Bold)
    $brushBadge = New-Object System.Drawing.SolidBrush($AccentColor)
    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
    $sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($CategoryBadge.ToUpper(), $fontBadge, $brushBadge, [System.Drawing.RectangleF]::new(80, 80, 360, 60), $sfCenter)
    $fontBadge.Dispose()
    $brushBadge.Dispose()

    # 5. Venue Title
    $fontVenue = New-Object System.Drawing.Font("Arial", 46, [System.Drawing.FontStyle]::Bold)
    $brushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.DrawString($VenueTitle, $fontVenue, $brushWhite, [System.Drawing.RectangleF]::new(80, 220, $Width - 160, 120))
    $fontVenue.Dispose()

    # Accent underline
    $linePen = New-Object System.Drawing.Pen($AccentColor, 8)
    $g.DrawLine($linePen, 80, 350, 420, 350)
    $linePen.Dispose()

    # 6. Event Main Headline
    $fontHeadline = New-Object System.Drawing.Font("Arial", 56, [System.Drawing.FontStyle]::Bold)
    $brushAccent = New-Object System.Drawing.SolidBrush($AccentColor)
    $g.DrawString($EventHeadline, $fontHeadline, $brushAccent, [System.Drawing.RectangleF]::new(80, 390, $Width - 160, 260))
    $fontHeadline.Dispose()
    $brushAccent.Dispose()

    # 7. Subheadline / Description
    $fontSub = New-Object System.Drawing.Font("Arial", 28, [System.Drawing.FontStyle]::Regular)
    $brushMuted = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 226, 232))
    $g.DrawString($EventSubheadline, $fontSub, $brushMuted, [System.Drawing.RectangleF]::new(80, 660, $Width - 160, 160))
    $fontSub.Dispose()
    $brushMuted.Dispose()

    # 8. Date & Time Block
    $boxW = $Width - 160
    $dateBox = New-Object System.Drawing.Rectangle(80, 850, $boxW, 130)
    $dateBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 15, 23, 42))
    $g.FillRectangle($dateBg, $dateBox)
    $dateBg.Dispose()

    $dateBorder = New-Object System.Drawing.Pen($SecondaryColor, 3)
    $g.DrawRectangle($dateBorder, $dateBox)
    $dateBorder.Dispose()

    $fontDate = New-Object System.Drawing.Font("Arial", 30, [System.Drawing.FontStyle]::Bold)
    $brushSec = New-Object System.Drawing.SolidBrush($SecondaryColor)
    $dateTextW = [float]($Width - 220)
    $g.DrawString($DateString, $fontDate, $brushSec, [System.Drawing.RectangleF]::new(110, 885, $dateTextW, 70))
    $fontDate.Dispose()
    $brushSec.Dispose()

    # 9. Promo Tag Pill (e.g. "PROMO 2X1 SNACKS & DRINKS")
    if ($PromoTag) {
        $promoRect = New-Object System.Drawing.Rectangle(80, 1010, $boxW, 100)
        $promoBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, $AccentColor.R, $AccentColor.G, $AccentColor.B))
        $g.FillRectangle($promoBg, $promoRect)
        $promoBg.Dispose()

        $fontPromo = New-Object System.Drawing.Font("Arial", 26, [System.Drawing.FontStyle]::Bold)
        $brushDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))
        $g.DrawString($PromoTag, $fontPromo, $brushDark, [System.Drawing.RectangleF]::new(80, 1010, $boxW, 100), $sfCenter)
        $fontPromo.Dispose()
        $brushDark.Dispose()
    }

    # 10. Bottom Instagram footer
    $fontIg = New-Object System.Drawing.Font("Arial", 22, [System.Drawing.FontStyle]::Bold)
    $brushIg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 255, 255, 255))
    $g.DrawString("OFICIAL IG: $InstagramHandle  •  COLIMA NIGHT", $fontIg, $brushIg, [System.Drawing.RectangleF]::new(80, 1220, $Width - 160, 60), $sfCenter)
    $fontIg.Dispose()
    $brushIg.Dispose()

    $sfCenter.Dispose()
    $brushWhite.Dispose()
    $g.Dispose()

    # Save as high-quality JPEG
    $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.FormatDescription -eq 'JPEG' }
    $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 92L)
    $bmp.Save($Path, $encoder, $encParams)
    $encParams.Dispose()
    $bmp.Dispose()
    Write-Host "Created flyer: $Path"
}

# Create Bar La Puerta Flyer
Create-Flyer `
    -Path "assets/images/venues/flyers/bar_la_puerta_flyer.jpg" `
    -BgTop ([System.Drawing.Color]::FromArgb(25, 10, 18)) `
    -BgBottom ([System.Drawing.Color]::FromArgb(50, 12, 28)) `
    -AccentColor ([System.Drawing.Color]::FromArgb(244, 63, 94)) `
    -SecondaryColor ([System.Drawing.Color]::FromArgb(251, 191, 36)) `
    -CategoryBadge "Bar Urbano & Snacks" `
    -VenueTitle "BAR LA PUERTA" `
    -EventHeadline "JUEVES DE SNACKS & DRINKS" `
    -EventSubheadline "A partir de las 7:00 PM. Botanas, alitas, caguamas frías y perreo clásico en el corazón del Centro Histórico." `
    -DateString "TODOS LOS JUEVES  •  7:00 PM - CIERRE" `
    -PromoTag "2X1 EN CERVEZAS NACIONALES & SNACKS" `
    -InstagramHandle "@barlapuerta" `
    -StylePattern "waves"

# Create Guachi Rooftop Flyer
Create-Flyer `
    -Path "assets/images/venues/flyers/guachi_rooftop_flyer.jpg" `
    -BgTop ([System.Drawing.Color]::FromArgb(20, 10, 35)) `
    -BgBottom ([System.Drawing.Color]::FromArgb(60, 20, 80)) `
    -AccentColor ([System.Drawing.Color]::FromArgb(255, 140, 0)) `
    -SecondaryColor ([System.Drawing.Color]::FromArgb(168, 85, 247)) `
    -CategoryBadge "Rooftop & Terraza" `
    -VenueTitle "GUACHI ROOFTOP" `
    -EventHeadline "SUNSET ELECTRONIC SESSIONS" `
    -EventSubheadline "Tech-House & Deep Sunset con mixología de autor, vista panorámica al volcán y alineación de DJs invitados." `
    -DateString "VIERNES & SÁBADOS  •  6:00 PM EN ADELANTE" `
    -PromoTag "COCTELERÍA DE AUTOR & SUNSET VIBES" `
    -InstagramHandle "@guachirooftop" `
    -StylePattern "sunset"

# Create Dos Puntos Taproom Flyer
Create-Flyer `
    -Path "assets/images/venues/flyers/dos_puntos_flyer.jpg" `
    -BgTop ([System.Drawing.Color]::FromArgb(10, 25, 25)) `
    -BgBottom ([System.Drawing.Color]::FromArgb(15, 45, 40)) `
    -AccentColor ([System.Drawing.Color]::FromArgb(45, 212, 191)) `
    -SecondaryColor ([System.Drawing.Color]::FromArgb(250, 204, 21)) `
    -CategoryBadge "Taproom & Jardín" `
    -VenueTitle "DOS PUNTOS" `
    -EventHeadline "CRAFT BEER & INDIE NIGHTS" `
    -EventSubheadline "Líneas de cerveza artesanal en barril, jardín al aire libre, hamburguesas smash y sesiones de vinilo." `
    -DateString "MIÉRCOLES A SÁBADO  •  6:00 PM - 1:00 AM" `
    -PromoTag "PINTA ARTESANAL & SAMPLERS ESPECIALES" `
    -InstagramHandle "@dospuntoscolima" `
    -StylePattern "taproom"

# Create Low Social Club Flyer
Create-Flyer `
    -Path "assets/images/venues/flyers/low_social_flyer.jpg" `
    -BgTop ([System.Drawing.Color]::FromArgb(8, 8, 20)) `
    -BgBottom ([System.Drawing.Color]::FromArgb(25, 15, 45)) `
    -AccentColor ([System.Drawing.Color]::FromArgb(192, 132, 252)) `
    -SecondaryColor ([System.Drawing.Color]::FromArgb(56, 189, 248)) `
    -CategoryBadge "Club Electrónico" `
    -VenueTitle "LOW SOCIAL CLUB" `
    -EventHeadline "UNDERGROUND TECH & AFRO HOUSE" `
    -EventSubheadline "Club nocturno con atmósfera minimalista, sistema de sonido de alta fidelidad y residentes de música electrónica." `
    -DateString "JUEVES, VIERNES & SÁBADO  •  10:00 PM - 5:00 AM" `
    -PromoTag "COVER INCLUYE DRINK DE BIENVENIDA" `
    -InstagramHandle "@lowsocialclub" `
    -StylePattern "lasers"

# Create Foro DMT Rock Flyer
Create-Flyer `
    -Path "assets/images/venues/flyers/foro_dmt_rock_flyer.jpg" `
    -BgTop ([System.Drawing.Color]::FromArgb(25, 15, 10)) `
    -BgBottom ([System.Drawing.Color]::FromArgb(45, 20, 10)) `
    -AccentColor ([System.Drawing.Color]::FromArgb(249, 115, 22)) `
    -SecondaryColor ([System.Drawing.Color]::FromArgb(239, 68, 68)) `
    -CategoryBadge "Foro Cultural & Rock" `
    -VenueTitle "FORO DMT" `
    -EventHeadline "NOCHE DE ROCK EN VIVO & TRIBUTOS" `
    -EventSubheadline "Bandas locales en vivo, tributos al rock en español y grunge independiente. El templo del rock en Colima." `
    -DateString "VIERNES & SÁBADO  •  9:00 PM - 3:00 AM" `
    -PromoTag "CUBETAZO DE CERVEZA & ENTRADA LIBRE ANTES DE 10 PM" `
    -InstagramHandle "@foro_dmt" `
    -StylePattern "grunge"

# Create Bar La Puerta Venue Photo Replacement
function Create-VenuePhoto {
    param(
        [string]$Path,
        [int]$Width = 1200,
        [int]$Height = 800,
        [System.Drawing.Color]$AmbTop,
        [System.Drawing.Color]$AmbBottom,
        [string]$Title,
        [string]$Subtitle
    )

    $bmp = New-Object System.Drawing.Bitmap($Width, $Height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    $rect = New-Object System.Drawing.Rectangle(0, 0, $Width, $Height)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $AmbTop, $AmbBottom, [System.Drawing.Drawing2D.LinearGradientMode]::BackwardDiagonal)
    $g.FillRectangle($bgBrush, $rect)
    $bgBrush.Dispose()

    # Atmospheric lights & wooden bar shelves
    $barBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 35, 18, 12))
    $g.FillRectangle($barBrush, 0, 480, $Width, 320)
    $barBrush.Dispose()

    # Counter top
    $counterBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 60, 30, 20))
    $g.FillRectangle($counterBrush, 0, 480, $Width, 40)
    $counterBrush.Dispose()

    # Neon sign glow
    $neonGlow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(70, 244, 63, 94))
    $g.FillEllipse($neonGlow, 350, 100, 500, 220)
    $neonGlow.Dispose()

    $fontTitle = New-Object System.Drawing.Font("Arial", 52, [System.Drawing.FontStyle]::Bold)
    $brushNeon = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 244, 63, 94))
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($Title, $fontTitle, $brushNeon, [System.Drawing.RectangleF]::new(0, 140, $Width, 80), $sf)
    $fontTitle.Dispose()
    $brushNeon.Dispose()

    $fontSub = New-Object System.Drawing.Font("Arial", 22, [System.Drawing.FontStyle]::Regular)
    $brushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 255, 255, 255))
    $g.DrawString($Subtitle, $fontSub, $brushWhite, [System.Drawing.RectangleF]::new(0, 230, $Width, 50), $sf)
    $fontSub.Dispose()
    $brushWhite.Dispose()
    $sf.Dispose()
    $g.Dispose()

    $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.FormatDescription -eq 'JPEG' }
    $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 92L)
    $bmp.Save($Path, $encoder, $encParams)
    $encParams.Dispose()
    $bmp.Dispose()
    Write-Host "Created venue photo: $Path"
}

Create-VenuePhoto `
    -Path "assets/images/venues/bar_la_puerta.jpg" `
    -AmbTop ([System.Drawing.Color]::FromArgb(25, 12, 18)) `
    -AmbBottom ([System.Drawing.Color]::FromArgb(45, 15, 25)) `
    -Title "BAR LA PUERTA" `
    -Subtitle "Ambiente Urbano & Cerveza de Barrio • Centro de Colima"

Copy-Item "assets/images/venues/bar_la_puerta.jpg" "assets/images/venues/la_puerta_bar.jpg" -Force
