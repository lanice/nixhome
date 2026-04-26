#!/usr/bin/env bash
# Dump rich EXIF metadata as CSV for all JPEGs in cwd.
exec exiftool -csv \
  -FileName -DateTimeOriginal -Model -Aperture -ExposureTime -ISO \
  -LensInfo -FocalLengthIn35mmFormat -Flash -MeteringMode -FileSize \
  -ImageSize -Megapixels -ShootingMode -WhiteBalance -ColorTemperature \
  -NoiseReduction -AFAreaMode -AFPointSel -AF-CPrioritySel -FocusMode \
  -AF-SPrioritySel -FocusDistance -HyperfocalDistance -SubjectDistance \
  -AFAreaWidth -AFAreaXPosition -AFAreaYPosition -AFDetectionMethod \
  -Brightness -CenterWeightedAreaSize -Clarity -ColorTemperatureAuto \
  -Contrast -Copyright -Exposure -ExposureBracketValue \
  -ExposureCompensation -ExposureMode -FOV -HighlightRecovery \
  -LightValue -NumberOfImages -PitchAngle -RecommendedExposureIndex \
  -ReleaseMode -RollAngle -SelfTimerShotInterval -SelfTimerTime \
  -Shadows -Vibrance -VibrationReduction -YawAngle -ImageHeight \
  -ImageWidth \
  -ext jpg -ext JPG -ext jpeg -ext JPEG \
  .
