$OG = 1.040 #Ref/Hyd
$FG = 1.015 #Refractometer
$FG_Brix = (((182.4601 * $FG -775.6821) * $FG +1262.7794) * $FG -669.5622)
$Refractometer_correction = 1.000

#Refraktometer
$delta = 0.372*(1/(1-$FG_Brix/261)-1)
$Corrected_FG = 1.002 - 0.5815 * ($OG - 1.000) + 3.96*$delta + 5.3 * $delta * $delta
$Corrected_FG_SG = $Corrected_FG * $Refractometer_correction
$Corrected_FG_Brix = (((182.4601 * $Corrected_FG_SG - 775.6821) * $Corrected_FG_SG + 1262.7794) * $Corrected_FG_SG - 669.5622)

#Temp correction
$TR = 20  #temperature at time of reading
$TC = 20 #calibration temperature of hydrometer
$CG_FG = $Corrected_FG_SG * ((1.00130346 - 0.000134722124 * $TR + 0.00000204052596 * $TR - 0.00000000232820948 * $TR) / (1.00130346 - 0.000134722124 * $TC + 0.00000204052596 * $TC - 0.00000000232820948 * $TC))
$CG_OG = $OG * ((1.00130346 - 0.000134722124 * $TR + 0.00000204052596 * $TR - 0.00000000232820948 * $TR) / (1.00130346 - 0.000134722124 * $TC + 0.00000204052596 * $TC - 0.00000000232820948 * $TC))

#ABV
$ABV = (76.08 * ($CG_OG-$CG_FG) / (1.775-$CG_OG)) * ($CG_FG / 0.794)
$ABV


