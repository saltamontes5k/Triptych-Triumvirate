-- Hero's Forge armor ornament model backfill
-- Source: Heros_Forge_Mappings.pdf (full value = base model x100 + slot; Helm0 Chest1 Arms2 Wrist3 Hands4 Legs5 Feet6 Robe7)
-- Matches existing Glamour rows (e.g. Grizzly = 14500). Stock IT64 armor ornaments only; Glamour rows untouched.
-- Idempotent per-id UPDATEs; re-run shared_memory after applying.
-- Rows: 417 across 417 models

-- model 2000
UPDATE items SET herosforgemodel = 2000 WHERE id = 87623; -- Hero's Forge Plate Helm Ornament

-- model 2001
UPDATE items SET herosforgemodel = 2001 WHERE id = 87624; -- Hero's Forge Plate Chest Ornament

-- model 2002
UPDATE items SET herosforgemodel = 2002 WHERE id = 87625; -- Hero's Forge Plate Arms Ornament

-- model 2003
UPDATE items SET herosforgemodel = 2003 WHERE id = 87626; -- Hero's Forge Plate Wrist Ornament

-- model 2004
UPDATE items SET herosforgemodel = 2004 WHERE id = 87627; -- Hero's Forge Plate Hands Ornament

-- model 2005
UPDATE items SET herosforgemodel = 2005 WHERE id = 87628; -- Hero's Forge Plate Legs Ornament

-- model 2006
UPDATE items SET herosforgemodel = 2006 WHERE id = 87629; -- Hero's Forge Plate Feet Ornament

-- model 3000
UPDATE items SET herosforgemodel = 3000 WHERE id = 87609; -- Hero's Forge Leather Helm Ornament

-- model 3001
UPDATE items SET herosforgemodel = 3001 WHERE id = 87610; -- Hero's Forge Leather Chest Ornament

-- model 3002
UPDATE items SET herosforgemodel = 3002 WHERE id = 87611; -- Hero's Forge Leather Arms Ornament

-- model 3003
UPDATE items SET herosforgemodel = 3003 WHERE id = 87612; -- Hero's Forge Leather Wrist Ornament

-- model 3004
UPDATE items SET herosforgemodel = 3004 WHERE id = 87613; -- Hero's Forge Leather Hands Ornament

-- model 3005
UPDATE items SET herosforgemodel = 3005 WHERE id = 87614; -- Hero's Forge Leather Legs Ornament

-- model 3006
UPDATE items SET herosforgemodel = 3006 WHERE id = 87615; -- Hero's Forge Leather Feet Ornament

-- model 4000
UPDATE items SET herosforgemodel = 4000 WHERE id = 87616; -- Hero's Forge Chain Helm Ornament

-- model 4001
UPDATE items SET herosforgemodel = 4001 WHERE id = 87617; -- Hero's Forge Chain Chest Ornament

-- model 4002
UPDATE items SET herosforgemodel = 4002 WHERE id = 87618; -- Hero's Forge Chain Arms Ornament

-- model 4003
UPDATE items SET herosforgemodel = 4003 WHERE id = 87619; -- Hero's Forge Chain Wrist Ornament

-- model 4004
UPDATE items SET herosforgemodel = 4004 WHERE id = 87620; -- Hero's Forge Chain Hands Ornament

-- model 4005
UPDATE items SET herosforgemodel = 4005 WHERE id = 87621; -- Hero's Forge Chain Legs Ornament

-- model 4006
UPDATE items SET herosforgemodel = 4006 WHERE id = 87622; -- Hero's Forge Chain Feet Ornament

-- model 5000
UPDATE items SET herosforgemodel = 5000 WHERE id = 87601; -- Hero's Forge Cloth Helm Ornament

-- model 5001
UPDATE items SET herosforgemodel = 5001 WHERE id = 87602; -- Hero's Forge Cloth Chest Ornament

-- model 5002
UPDATE items SET herosforgemodel = 5002 WHERE id = 87603; -- Hero's Forge Cloth Arms Ornament

-- model 5003
UPDATE items SET herosforgemodel = 5003 WHERE id = 87604; -- Hero's Forge Cloth Wrist Ornament

-- model 5004
UPDATE items SET herosforgemodel = 5004 WHERE id = 87605; -- Hero's Forge Cloth Hands Ornament

-- model 5005
UPDATE items SET herosforgemodel = 5005 WHERE id = 87606; -- Hero's Forge Cloth Legs Ornament

-- model 5006
UPDATE items SET herosforgemodel = 5006 WHERE id = 87607; -- Hero's Forge Cloth Feet Ornament

-- model 5007
UPDATE items SET herosforgemodel = 5007 WHERE id = 87608; -- Hero's Forge Cloth Robe Ornament

-- model 6000
UPDATE items SET herosforgemodel = 6000 WHERE id = 87630; -- Noble Plate Helm Ornament

-- model 6001
UPDATE items SET herosforgemodel = 6001 WHERE id = 87631; -- Noble Plate Chest Ornament

-- model 6002
UPDATE items SET herosforgemodel = 6002 WHERE id = 87632; -- Noble Plate Arms Ornament

-- model 6003
UPDATE items SET herosforgemodel = 6003 WHERE id = 87633; -- Noble Plate Wrist Ornament

-- model 6004
UPDATE items SET herosforgemodel = 6004 WHERE id = 87634; -- Noble Plate Hands Ornament

-- model 6005
UPDATE items SET herosforgemodel = 6005 WHERE id = 87635; -- Noble Plate Legs Ornament

-- model 6006
UPDATE items SET herosforgemodel = 6006 WHERE id = 87636; -- Noble Plate Feet Ornament

-- model 6100
UPDATE items SET herosforgemodel = 6100 WHERE id = 87659; -- Bloodforged Plate Helm Ornament

-- model 6101
UPDATE items SET herosforgemodel = 6101 WHERE id = 87660; -- Bloodforged Plate Chest Ornament

-- model 6102
UPDATE items SET herosforgemodel = 6102 WHERE id = 87661; -- Bloodforged Plate Arms Ornament

-- model 6103
UPDATE items SET herosforgemodel = 6103 WHERE id = 87662; -- Bloodforged Plate Wrist Ornament

-- model 6104
UPDATE items SET herosforgemodel = 6104 WHERE id = 87663; -- Bloodforged Plate Hands Ornament

-- model 6105
UPDATE items SET herosforgemodel = 6105 WHERE id = 87664; -- Bloodforged Plate Legs Ornament

-- model 6106
UPDATE items SET herosforgemodel = 6106 WHERE id = 87665; -- Bloodforged Plate Feet Ornament

-- model 6200
UPDATE items SET herosforgemodel = 6200 WHERE id = 87688; -- Sylvan Plate Helm Ornament

-- model 6201
UPDATE items SET herosforgemodel = 6201 WHERE id = 87689; -- Sylvan Plate Chest Ornament

-- model 6202
UPDATE items SET herosforgemodel = 6202 WHERE id = 87690; -- Sylvan Plate Arms Ornament

-- model 6203
UPDATE items SET herosforgemodel = 6203 WHERE id = 87691; -- Sylvan Plate Wrist Ornament

-- model 6204
UPDATE items SET herosforgemodel = 6204 WHERE id = 87692; -- Sylvan Plate Hands Ornament

-- model 6205
UPDATE items SET herosforgemodel = 6205 WHERE id = 87693; -- Sylvan Plate Legs Ornament

-- model 6206
UPDATE items SET herosforgemodel = 6206 WHERE id = 87694; -- Sylvan Plate Feet Ornament

-- model 6300
UPDATE items SET herosforgemodel = 6300 WHERE id = 87717; -- Valiant Plate Helm Ornament

-- model 6301
UPDATE items SET herosforgemodel = 6301 WHERE id = 87718; -- Valiant Plate Chest Ornament

-- model 6302
UPDATE items SET herosforgemodel = 6302 WHERE id = 87719; -- Valiant Plate Arms Ornament

-- model 6303
UPDATE items SET herosforgemodel = 6303 WHERE id = 87720; -- Valiant Plate Wrist Ornament

-- model 6304
UPDATE items SET herosforgemodel = 6304 WHERE id = 87721; -- Valiant Plate Hands Ornament

-- model 6305
UPDATE items SET herosforgemodel = 6305 WHERE id = 87722; -- Valiant Plate Legs Ornament

-- model 6306
UPDATE items SET herosforgemodel = 6306 WHERE id = 87723; -- Valiant Plate Feet Ornament

-- model 6400
UPDATE items SET herosforgemodel = 6400 WHERE id = 87746; -- Insidious Plate Helm Ornament

-- model 6401
UPDATE items SET herosforgemodel = 6401 WHERE id = 87747; -- Insidious Plate Chest Ornament

-- model 6402
UPDATE items SET herosforgemodel = 6402 WHERE id = 87748; -- Insidious Plate Arms Ornament

-- model 6403
UPDATE items SET herosforgemodel = 6403 WHERE id = 87749; -- Insidious Plate Wrist Ornament

-- model 6404
UPDATE items SET herosforgemodel = 6404 WHERE id = 87750; -- Insidious Plate Hands Ornament

-- model 6405
UPDATE items SET herosforgemodel = 6405 WHERE id = 87751; -- Insidious Plate Legs Ornament

-- model 6406
UPDATE items SET herosforgemodel = 6406 WHERE id = 87752; -- Insidious Plate Feet Ornament

-- model 6500
UPDATE items SET herosforgemodel = 6500 WHERE id = 87775; -- Eternal Grove Plate Helm Ornament

-- model 6501
UPDATE items SET herosforgemodel = 6501 WHERE id = 87776; -- Eternal Grove Plate Chest Ornament

-- model 6502
UPDATE items SET herosforgemodel = 6502 WHERE id = 87777; -- Eternal Grove Plate Arms Ornament

-- model 6503
UPDATE items SET herosforgemodel = 6503 WHERE id = 87778; -- Eternal Grove Plate Wrist Ornament

-- model 6504
UPDATE items SET herosforgemodel = 6504 WHERE id = 87779; -- Eternal Grove Plate Hands Ornament

-- model 6505
UPDATE items SET herosforgemodel = 6505 WHERE id = 87780; -- Eternal Grove Plate Legs Ornament

-- model 6506
UPDATE items SET herosforgemodel = 6506 WHERE id = 87781; -- Eternal Grove Plate Feet Ornament

-- model 7000
UPDATE items SET herosforgemodel = 7000 WHERE id = 87637; -- Noble Chain Helm Ornament

-- model 7001
UPDATE items SET herosforgemodel = 7001 WHERE id = 87638; -- Noble Chain Chest Ornament

-- model 7002
UPDATE items SET herosforgemodel = 7002 WHERE id = 87639; -- Noble Chain Arms Ornament

-- model 7003
UPDATE items SET herosforgemodel = 7003 WHERE id = 87640; -- Noble Chain Wrist Ornament

-- model 7004
UPDATE items SET herosforgemodel = 7004 WHERE id = 87641; -- Noble Chain Hands Ornament

-- model 7005
UPDATE items SET herosforgemodel = 7005 WHERE id = 87642; -- Noble Chain Legs Ornament

-- model 7006
UPDATE items SET herosforgemodel = 7006 WHERE id = 87643; -- Noble Chain Feet Ornament

-- model 7100
UPDATE items SET herosforgemodel = 7100 WHERE id = 87666; -- Bloodforged Chain Helm Ornament

-- model 7101
UPDATE items SET herosforgemodel = 7101 WHERE id = 87667; -- Bloodforged Chain Chest Ornament

-- model 7102
UPDATE items SET herosforgemodel = 7102 WHERE id = 87668; -- Bloodforged Chain Arms Ornament

-- model 7103
UPDATE items SET herosforgemodel = 7103 WHERE id = 87669; -- Bloodforged Chain Wrist Ornament

-- model 7104
UPDATE items SET herosforgemodel = 7104 WHERE id = 87670; -- Bloodforged Chain Hands Ornament

-- model 7105
UPDATE items SET herosforgemodel = 7105 WHERE id = 87671; -- Bloodforged Chain Legs Ornament

-- model 7106
UPDATE items SET herosforgemodel = 7106 WHERE id = 87672; -- Bloodforged Chain Feet Ornament

-- model 7200
UPDATE items SET herosforgemodel = 7200 WHERE id = 87695; -- Sylvan Chain Helm Ornament

-- model 7201
UPDATE items SET herosforgemodel = 7201 WHERE id = 87696; -- Sylvan Chain Chest Ornament

-- model 7202
UPDATE items SET herosforgemodel = 7202 WHERE id = 87697; -- Sylvan Chain Arms Ornament

-- model 7203
UPDATE items SET herosforgemodel = 7203 WHERE id = 87698; -- Sylvan Chain Wrist Ornament

-- model 7204
UPDATE items SET herosforgemodel = 7204 WHERE id = 87699; -- Sylvan Chain Hands Ornament

-- model 7205
UPDATE items SET herosforgemodel = 7205 WHERE id = 87700; -- Sylvan Chain Legs Ornament

-- model 7206
UPDATE items SET herosforgemodel = 7206 WHERE id = 87701; -- Sylvan Chain Feet Ornament

-- model 7300
UPDATE items SET herosforgemodel = 7300 WHERE id = 87724; -- Valiant Chain Helm Ornament

-- model 7301
UPDATE items SET herosforgemodel = 7301 WHERE id = 87725; -- Valiant Chain Chest Ornament

-- model 7302
UPDATE items SET herosforgemodel = 7302 WHERE id = 87726; -- Valiant Chain Arms Ornament

-- model 7303
UPDATE items SET herosforgemodel = 7303 WHERE id = 87727; -- Valiant Chain Wrist Ornament

-- model 7304
UPDATE items SET herosforgemodel = 7304 WHERE id = 87728; -- Valiant Chain Hands Ornament

-- model 7305
UPDATE items SET herosforgemodel = 7305 WHERE id = 87729; -- Valiant Chain Legs Ornament

-- model 7306
UPDATE items SET herosforgemodel = 7306 WHERE id = 87730; -- Valiant Chain Feet Ornament

-- model 7400
UPDATE items SET herosforgemodel = 7400 WHERE id = 87753; -- Insidious Chain Helm Ornament

-- model 7401
UPDATE items SET herosforgemodel = 7401 WHERE id = 87754; -- Insidious Chain Chest Ornament

-- model 7402
UPDATE items SET herosforgemodel = 7402 WHERE id = 87755; -- Insidious Chain Arms Ornament

-- model 7403
UPDATE items SET herosforgemodel = 7403 WHERE id = 87756; -- Insidious Chain Wrist Ornament

-- model 7404
UPDATE items SET herosforgemodel = 7404 WHERE id = 87757; -- Insidious Chain Hands Ornament

-- model 7405
UPDATE items SET herosforgemodel = 7405 WHERE id = 87758; -- Insidious Chain Legs Ornament

-- model 7406
UPDATE items SET herosforgemodel = 7406 WHERE id = 87759; -- Insidious Chain Feet Ornament

-- model 7500
UPDATE items SET herosforgemodel = 7500 WHERE id = 87782; -- Eternal Grove Chain Helm Ornament

-- model 7501
UPDATE items SET herosforgemodel = 7501 WHERE id = 87783; -- Eternal Grove Chain Chest Ornament

-- model 7502
UPDATE items SET herosforgemodel = 7502 WHERE id = 87784; -- Eternal Grove Chain Arms Ornament

-- model 7503
UPDATE items SET herosforgemodel = 7503 WHERE id = 87785; -- Eternal Grove Chain Wrist Ornament

-- model 7504
UPDATE items SET herosforgemodel = 7504 WHERE id = 87786; -- Eternal Grove Chain Hands Ornament

-- model 7505
UPDATE items SET herosforgemodel = 7505 WHERE id = 87787; -- Eternal Grove Chain Legs Ornament

-- model 7506
UPDATE items SET herosforgemodel = 7506 WHERE id = 87788; -- Eternal Grove Chain Feet Ornament

-- model 8000
UPDATE items SET herosforgemodel = 8000 WHERE id = 87644; -- Noble Leather Helm Ornament

-- model 8001
UPDATE items SET herosforgemodel = 8001 WHERE id = 87645; -- Noble Leather Chest Ornament

-- model 8002
UPDATE items SET herosforgemodel = 8002 WHERE id = 87646; -- Noble Leather Arms Ornament

-- model 8003
UPDATE items SET herosforgemodel = 8003 WHERE id = 87647; -- Noble Leather Wrist Ornament

-- model 8004
UPDATE items SET herosforgemodel = 8004 WHERE id = 87648; -- Noble Leather Hands Ornament

-- model 8005
UPDATE items SET herosforgemodel = 8005 WHERE id = 87649; -- Noble Leather Legs Ornament

-- model 8006
UPDATE items SET herosforgemodel = 8006 WHERE id = 87650; -- Noble Leather Feet Ornament

-- model 8100
UPDATE items SET herosforgemodel = 8100 WHERE id = 87673; -- Bloodforged Leather Helm Ornament

-- model 8101
UPDATE items SET herosforgemodel = 8101 WHERE id = 87674; -- Bloodforged Leather Chest Ornament

-- model 8102
UPDATE items SET herosforgemodel = 8102 WHERE id = 87675; -- Bloodforged Leather Arms Ornament

-- model 8103
UPDATE items SET herosforgemodel = 8103 WHERE id = 87676; -- Bloodforged Leather Wrist Ornament

-- model 8104
UPDATE items SET herosforgemodel = 8104 WHERE id = 87677; -- Bloodforged Leather Hands Ornament

-- model 8105
UPDATE items SET herosforgemodel = 8105 WHERE id = 87678; -- Bloodforged Leather Legs Ornament

-- model 8106
UPDATE items SET herosforgemodel = 8106 WHERE id = 87679; -- Bloodforged Leather Feet Ornament

-- model 8200
UPDATE items SET herosforgemodel = 8200 WHERE id = 87702; -- Sylvan Leather Helm Ornament

-- model 8201
UPDATE items SET herosforgemodel = 8201 WHERE id = 87703; -- Sylvan Leather Chest Ornament

-- model 8202
UPDATE items SET herosforgemodel = 8202 WHERE id = 87704; -- Sylvan Leather Arms Ornament

-- model 8203
UPDATE items SET herosforgemodel = 8203 WHERE id = 87705; -- Sylvan Leather Wrist Ornament

-- model 8204
UPDATE items SET herosforgemodel = 8204 WHERE id = 87706; -- Sylvan Leather Hands Ornament

-- model 8205
UPDATE items SET herosforgemodel = 8205 WHERE id = 87707; -- Sylvan Leather Legs Ornament

-- model 8206
UPDATE items SET herosforgemodel = 8206 WHERE id = 87708; -- Sylvan Leather Feet Ornament

-- model 8300
UPDATE items SET herosforgemodel = 8300 WHERE id = 87731; -- Valiant Leather Helm Ornament

-- model 8301
UPDATE items SET herosforgemodel = 8301 WHERE id = 87732; -- Valiant Leather Chest Ornament

-- model 8302
UPDATE items SET herosforgemodel = 8302 WHERE id = 87733; -- Valiant Leather Arms Ornament

-- model 8303
UPDATE items SET herosforgemodel = 8303 WHERE id = 87734; -- Valiant Leather Wrist Ornament

-- model 8304
UPDATE items SET herosforgemodel = 8304 WHERE id = 87735; -- Valiant Leather Hands Ornament

-- model 8305
UPDATE items SET herosforgemodel = 8305 WHERE id = 87736; -- Valiant Leather Legs Ornament

-- model 8306
UPDATE items SET herosforgemodel = 8306 WHERE id = 87737; -- Valiant Leather Feet Ornament

-- model 8400
UPDATE items SET herosforgemodel = 8400 WHERE id = 87760; -- Insidious Leather Helm Ornament

-- model 8401
UPDATE items SET herosforgemodel = 8401 WHERE id = 87761; -- Insidious Leather Chest Ornament

-- model 8402
UPDATE items SET herosforgemodel = 8402 WHERE id = 87762; -- Insidious Leather Arms Ornament

-- model 8403
UPDATE items SET herosforgemodel = 8403 WHERE id = 87763; -- Insidious Leather Wrist Ornament

-- model 8404
UPDATE items SET herosforgemodel = 8404 WHERE id = 87764; -- Insidious Leather Hands Ornament

-- model 8405
UPDATE items SET herosforgemodel = 8405 WHERE id = 87765; -- Insidious Leather Legs Ornament

-- model 8406
UPDATE items SET herosforgemodel = 8406 WHERE id = 87766; -- Insidious Leather Feet Ornament

-- model 8500
UPDATE items SET herosforgemodel = 8500 WHERE id = 87789; -- Eternal Grove Leather Helm Ornament

-- model 8501
UPDATE items SET herosforgemodel = 8501 WHERE id = 87790; -- Eternal Grove Leather Chest Ornament

-- model 8502
UPDATE items SET herosforgemodel = 8502 WHERE id = 87791; -- Eternal Grove Leather Arms Ornament

-- model 8503
UPDATE items SET herosforgemodel = 8503 WHERE id = 87792; -- Eternal Grove Leather Wrist Ornament

-- model 8504
UPDATE items SET herosforgemodel = 8504 WHERE id = 87793; -- Eternal Grove Leather Hands Ornament

-- model 8505
UPDATE items SET herosforgemodel = 8505 WHERE id = 87794; -- Eternal Grove Leather Legs Ornament

-- model 8506
UPDATE items SET herosforgemodel = 8506 WHERE id = 87795; -- Eternal Grove Leather Feet Ornament

-- model 9000
UPDATE items SET herosforgemodel = 9000 WHERE id = 87651; -- Noble Cloth Helm Ornament

-- model 9001
UPDATE items SET herosforgemodel = 9001 WHERE id = 87652; -- Noble Cloth Chest Ornament

-- model 9002
UPDATE items SET herosforgemodel = 9002 WHERE id = 87653; -- Noble Cloth Arms Ornament

-- model 9003
UPDATE items SET herosforgemodel = 9003 WHERE id = 87654; -- Noble Cloth Wrist Ornament

-- model 9004
UPDATE items SET herosforgemodel = 9004 WHERE id = 87655; -- Noble Cloth Hands Ornament

-- model 9005
UPDATE items SET herosforgemodel = 9005 WHERE id = 87656; -- Noble Cloth Legs Ornament

-- model 9006
UPDATE items SET herosforgemodel = 9006 WHERE id = 87657; -- Noble Cloth Feet Ornament

-- model 9007
UPDATE items SET herosforgemodel = 9007 WHERE id = 87658; -- Noble Cloth Robe Ornament

-- model 9100
UPDATE items SET herosforgemodel = 9100 WHERE id = 87680; -- Bloodforged Cloth Helm Ornament

-- model 9101
UPDATE items SET herosforgemodel = 9101 WHERE id = 87681; -- Bloodforged Cloth Chest Ornament

-- model 9102
UPDATE items SET herosforgemodel = 9102 WHERE id = 87682; -- Bloodforged Cloth Arms Ornament

-- model 9103
UPDATE items SET herosforgemodel = 9103 WHERE id = 87683; -- Bloodforged Cloth Wrist Ornament

-- model 9104
UPDATE items SET herosforgemodel = 9104 WHERE id = 87684; -- Bloodforged Cloth Hands Ornament

-- model 9105
UPDATE items SET herosforgemodel = 9105 WHERE id = 87685; -- Bloodforged Cloth Legs Ornament

-- model 9106
UPDATE items SET herosforgemodel = 9106 WHERE id = 87686; -- Bloodforged Cloth Feet Ornament

-- model 9107
UPDATE items SET herosforgemodel = 9107 WHERE id = 87687; -- Bloodforged Cloth Robe Ornament

-- model 9200
UPDATE items SET herosforgemodel = 9200 WHERE id = 87709; -- Sylvan Cloth Helm Ornament

-- model 9201
UPDATE items SET herosforgemodel = 9201 WHERE id = 87710; -- Sylvan Cloth Chest Ornament

-- model 9202
UPDATE items SET herosforgemodel = 9202 WHERE id = 87711; -- Sylvan Cloth Arms Ornament

-- model 9203
UPDATE items SET herosforgemodel = 9203 WHERE id = 87712; -- Sylvan Cloth Wrist Ornament

-- model 9204
UPDATE items SET herosforgemodel = 9204 WHERE id = 87713; -- Sylvan Cloth Hands Ornament

-- model 9205
UPDATE items SET herosforgemodel = 9205 WHERE id = 87714; -- Sylvan Cloth Legs Ornament

-- model 9206
UPDATE items SET herosforgemodel = 9206 WHERE id = 87715; -- Sylvan Cloth Feet Ornament

-- model 9207
UPDATE items SET herosforgemodel = 9207 WHERE id = 87716; -- Sylvan Cloth Robe Ornament

-- model 9300
UPDATE items SET herosforgemodel = 9300 WHERE id = 87738; -- Valiant Cloth Helm Ornament

-- model 9301
UPDATE items SET herosforgemodel = 9301 WHERE id = 87739; -- Valiant Cloth Chest Ornament

-- model 9302
UPDATE items SET herosforgemodel = 9302 WHERE id = 87740; -- Valiant Cloth Arms Ornament

-- model 9303
UPDATE items SET herosforgemodel = 9303 WHERE id = 87741; -- Valiant Cloth Wrist Ornament

-- model 9304
UPDATE items SET herosforgemodel = 9304 WHERE id = 87742; -- Valiant Cloth Hands Ornament

-- model 9305
UPDATE items SET herosforgemodel = 9305 WHERE id = 87743; -- Valiant Cloth Legs Ornament

-- model 9306
UPDATE items SET herosforgemodel = 9306 WHERE id = 87744; -- Valiant Cloth Feet Ornament

-- model 9307
UPDATE items SET herosforgemodel = 9307 WHERE id = 87745; -- Valiant Cloth Robe Ornament

-- model 9400
UPDATE items SET herosforgemodel = 9400 WHERE id = 87767; -- Insidious Cloth Helm Ornament

-- model 9401
UPDATE items SET herosforgemodel = 9401 WHERE id = 87768; -- Insidious Cloth Chest Ornament

-- model 9402
UPDATE items SET herosforgemodel = 9402 WHERE id = 87769; -- Insidious Cloth Arms Ornament

-- model 9403
UPDATE items SET herosforgemodel = 9403 WHERE id = 87770; -- Insidious Cloth Wrist Ornament

-- model 9404
UPDATE items SET herosforgemodel = 9404 WHERE id = 87771; -- Insidious Cloth Hands Ornament

-- model 9405
UPDATE items SET herosforgemodel = 9405 WHERE id = 87772; -- Insidious Cloth Legs Ornament

-- model 9406
UPDATE items SET herosforgemodel = 9406 WHERE id = 87773; -- Insidious Cloth Feet Ornament

-- model 9407
UPDATE items SET herosforgemodel = 9407 WHERE id = 87774; -- Insidious Cloth Robe Ornament

-- model 9500
UPDATE items SET herosforgemodel = 9500 WHERE id = 87796; -- Eternal Grove Cloth Helm Ornament

-- model 9501
UPDATE items SET herosforgemodel = 9501 WHERE id = 87797; -- Eternal Grove Cloth Chest Ornament

-- model 9502
UPDATE items SET herosforgemodel = 9502 WHERE id = 87798; -- Eternal Grove Cloth Arms Ornament

-- model 9503
UPDATE items SET herosforgemodel = 9503 WHERE id = 87799; -- Eternal Grove Cloth Wrist Ornament

-- model 9504
UPDATE items SET herosforgemodel = 9504 WHERE id = 87800; -- Eternal Grove Cloth Hands Ornament

-- model 9505
UPDATE items SET herosforgemodel = 9505 WHERE id = 87801; -- Eternal Grove Cloth Legs Ornament

-- model 9506
UPDATE items SET herosforgemodel = 9506 WHERE id = 87802; -- Eternal Grove Cloth Feet Ornament

-- model 9507
UPDATE items SET herosforgemodel = 9507 WHERE id = 87803; -- Eternal Grove Cloth Robe Ornament

-- model 9600
UPDATE items SET herosforgemodel = 9600 WHERE id = 87804; -- Ebon Hero's Forge Plate Helm Ornament

-- model 9601
UPDATE items SET herosforgemodel = 9601 WHERE id = 87805; -- Ebon Hero's Forge Plate Chest Ornament

-- model 9602
UPDATE items SET herosforgemodel = 9602 WHERE id = 87806; -- Ebon Hero's Forge Plate Arms Ornament

-- model 9603
UPDATE items SET herosforgemodel = 9603 WHERE id = 87807; -- Ebon Hero's Forge Plate Wrist Ornament

-- model 9604
UPDATE items SET herosforgemodel = 9604 WHERE id = 87808; -- Ebon Hero's Forge Plate Hands Ornament

-- model 9605
UPDATE items SET herosforgemodel = 9605 WHERE id = 87809; -- Ebon Hero's Forge Plate Legs Ornament

-- model 9606
UPDATE items SET herosforgemodel = 9606 WHERE id = 87810; -- Ebon Hero's Forge Plate Feet Ornament

-- model 9700
UPDATE items SET herosforgemodel = 9700 WHERE id = 87818; -- Ebon Hero's Forge Leather Helm Ornament

-- model 9701
UPDATE items SET herosforgemodel = 9701 WHERE id = 87819; -- Ebon Hero's Forge Leather Chest Ornament

-- model 9702
UPDATE items SET herosforgemodel = 9702 WHERE id = 87820; -- Ebon Hero's Forge Leather Arms Ornament

-- model 9703
UPDATE items SET herosforgemodel = 9703 WHERE id = 87821; -- Ebon Hero's Forge Leather Wrist Ornament

-- model 9704
UPDATE items SET herosforgemodel = 9704 WHERE id = 87822; -- Ebon Hero's Forge Leather Hands Ornament

-- model 9705
UPDATE items SET herosforgemodel = 9705 WHERE id = 87823; -- Ebon Hero's Forge Leather Legs Ornament

-- model 9706
UPDATE items SET herosforgemodel = 9706 WHERE id = 87824; -- Ebon Hero's Forge Leather Feet Ornament

-- model 9800
UPDATE items SET herosforgemodel = 9800 WHERE id = 87825; -- Ebon Hero's Forge Cloth Helm Ornament

-- model 9801
UPDATE items SET herosforgemodel = 9801 WHERE id = 87826; -- Ebon Hero's Forge Cloth Chest Ornament

-- model 9802
UPDATE items SET herosforgemodel = 9802 WHERE id = 87827; -- Ebon Hero's Forge Cloth Arms Ornament

-- model 9803
UPDATE items SET herosforgemodel = 9803 WHERE id = 87828; -- Ebon Hero's Forge Cloth Wrist Ornament

-- model 9804
UPDATE items SET herosforgemodel = 9804 WHERE id = 87829; -- Ebon Hero's Forge Cloth Hands Ornament

-- model 9805
UPDATE items SET herosforgemodel = 9805 WHERE id = 87830; -- Ebon Hero's Forge Cloth Legs Ornament

-- model 9806
UPDATE items SET herosforgemodel = 9806 WHERE id = 87831; -- Ebon Hero's Forge Cloth Feet Ornament

-- model 9807
UPDATE items SET herosforgemodel = 9807 WHERE id = 87832; -- Ebon Hero's Forge Cloth Robe Ornament

-- model 9900
UPDATE items SET herosforgemodel = 9900 WHERE id = 87811; -- Ebon Hero's Forge Chain Helm Ornament

-- model 9901
UPDATE items SET herosforgemodel = 9901 WHERE id = 87812; -- Ebon Hero's Forge Chain Chest Ornament

-- model 9902
UPDATE items SET herosforgemodel = 9902 WHERE id = 87813; -- Ebon Hero's Forge Chain Arms Ornament

-- model 9903
UPDATE items SET herosforgemodel = 9903 WHERE id = 87814; -- Ebon Hero's Forge Chain Wrist Ornament

-- model 9904
UPDATE items SET herosforgemodel = 9904 WHERE id = 87815; -- Ebon Hero's Forge Chain Hands Ornament

-- model 9905
UPDATE items SET herosforgemodel = 9905 WHERE id = 87816; -- Ebon Hero's Forge Chain Legs Ornament

-- model 9906
UPDATE items SET herosforgemodel = 9906 WHERE id = 87817; -- Ebon Hero's Forge Chain Feet Ornament

-- model 10000
UPDATE items SET herosforgemodel = 10000 WHERE id = 87833; -- Viridian Hero's Forge Plate Helm Ornament

-- model 10001
UPDATE items SET herosforgemodel = 10001 WHERE id = 87834; -- Viridian Hero's Forge Plate Chest Ornament

-- model 10002
UPDATE items SET herosforgemodel = 10002 WHERE id = 87835; -- Viridian Hero's Forge Plate Arms Ornament

-- model 10003
UPDATE items SET herosforgemodel = 10003 WHERE id = 87836; -- Viridian Hero's Forge Plate Wrist Ornament

-- model 10004
UPDATE items SET herosforgemodel = 10004 WHERE id = 87837; -- Viridian Hero's Forge Plate Hands Ornament

-- model 10005
UPDATE items SET herosforgemodel = 10005 WHERE id = 87838; -- Viridian Hero's Forge Plate Legs Ornament

-- model 10006
UPDATE items SET herosforgemodel = 10006 WHERE id = 87839; -- Viridian Hero's Forge Plate Feet Ornament

-- model 10100
UPDATE items SET herosforgemodel = 10100 WHERE id = 87847; -- Viridian Hero's Forge Leather Helm Ornament

-- model 10101
UPDATE items SET herosforgemodel = 10101 WHERE id = 87848; -- Viridian Hero's Forge Leather Chest Ornament

-- model 10102
UPDATE items SET herosforgemodel = 10102 WHERE id = 87849; -- Viridian Hero's Forge Leather Arms Ornament

-- model 10103
UPDATE items SET herosforgemodel = 10103 WHERE id = 87850; -- Viridian Hero's Forge Leather Wrist Ornament

-- model 10104
UPDATE items SET herosforgemodel = 10104 WHERE id = 87851; -- Viridian Hero's Forge Leather Hands Ornament

-- model 10105
UPDATE items SET herosforgemodel = 10105 WHERE id = 87852; -- Viridian Hero's Forge Leather Legs Ornament

-- model 10106
UPDATE items SET herosforgemodel = 10106 WHERE id = 87853; -- Viridian Hero's Forge Leather Feet Ornament

-- model 10200
UPDATE items SET herosforgemodel = 10200 WHERE id = 87854; -- Viridian Hero's Forge Cloth Helm Ornament

-- model 10201
UPDATE items SET herosforgemodel = 10201 WHERE id = 87855; -- Viridian Hero's Forge Cloth Chest Ornament

-- model 10202
UPDATE items SET herosforgemodel = 10202 WHERE id = 87856; -- Viridian Hero's Forge Cloth Arms Ornament

-- model 10203
UPDATE items SET herosforgemodel = 10203 WHERE id = 87857; -- Viridian Hero's Forge Cloth Wrist Ornament

-- model 10204
UPDATE items SET herosforgemodel = 10204 WHERE id = 87858; -- Viridian Hero's Forge Cloth Hands Ornament

-- model 10205
UPDATE items SET herosforgemodel = 10205 WHERE id = 87859; -- Viridian Hero's Forge Cloth Legs Ornament

-- model 10206
UPDATE items SET herosforgemodel = 10206 WHERE id = 87860; -- Viridian Hero's Forge Cloth Feet Ornament

-- model 10207
UPDATE items SET herosforgemodel = 10207 WHERE id = 87861; -- Viridian Hero's Forge Cloth Robe Ornament

-- model 10300
UPDATE items SET herosforgemodel = 10300 WHERE id = 87840; -- Viridian Hero's Forge Chain Helm Ornament

-- model 10301
UPDATE items SET herosforgemodel = 10301 WHERE id = 87841; -- Viridian Hero's Forge Chain Chest Ornament

-- model 10302
UPDATE items SET herosforgemodel = 10302 WHERE id = 87842; -- Viridian Hero's Forge Chain Arms Ornament

-- model 10303
UPDATE items SET herosforgemodel = 10303 WHERE id = 87843; -- Viridian Hero's Forge Chain Wrist Ornament

-- model 10304
UPDATE items SET herosforgemodel = 10304 WHERE id = 87844; -- Viridian Hero's Forge Chain Hands Ornament

-- model 10305
UPDATE items SET herosforgemodel = 10305 WHERE id = 87845; -- Viridian Hero's Forge Chain Legs Ornament

-- model 10306
UPDATE items SET herosforgemodel = 10306 WHERE id = 87846; -- Viridian Hero's Forge Chain Feet Ornament

-- model 10400
UPDATE items SET herosforgemodel = 10400 WHERE id = 87862; -- Violet Hero's Forge Plate Helm Ornament

-- model 10401
UPDATE items SET herosforgemodel = 10401 WHERE id = 87863; -- Violet Hero's Forge Plate Chest Ornament

-- model 10402
UPDATE items SET herosforgemodel = 10402 WHERE id = 87864; -- Violet Hero's Forge Plate Arms Ornament

-- model 10403
UPDATE items SET herosforgemodel = 10403 WHERE id = 87865; -- Violet Hero's Forge Plate Wrist Ornament

-- model 10404
UPDATE items SET herosforgemodel = 10404 WHERE id = 87866; -- Violet Hero's Forge Plate Hands Ornament

-- model 10405
UPDATE items SET herosforgemodel = 10405 WHERE id = 87867; -- Violet Hero's Forge Plate Legs Ornament

-- model 10406
UPDATE items SET herosforgemodel = 10406 WHERE id = 87868; -- Violet Hero's Forge Plate Feet Ornament

-- model 10500
UPDATE items SET herosforgemodel = 10500 WHERE id = 87876; -- Violet Hero's Forge Leather Helm Ornament

-- model 10501
UPDATE items SET herosforgemodel = 10501 WHERE id = 87877; -- Violet Hero's Forge Leather Chest Ornament

-- model 10502
UPDATE items SET herosforgemodel = 10502 WHERE id = 87878; -- Violet Hero's Forge Leather Arms Ornament

-- model 10503
UPDATE items SET herosforgemodel = 10503 WHERE id = 87879; -- Violet Hero's Forge Leather Wrist Ornament

-- model 10504
UPDATE items SET herosforgemodel = 10504 WHERE id = 87880; -- Violet Hero's Forge Leather Hands Ornament

-- model 10505
UPDATE items SET herosforgemodel = 10505 WHERE id = 87881; -- Violet Hero's Forge Leather Legs Ornament

-- model 10506
UPDATE items SET herosforgemodel = 10506 WHERE id = 87882; -- Violet Hero's Forge Leather Feet Ornament

-- model 10600
UPDATE items SET herosforgemodel = 10600 WHERE id = 87883; -- Violet Hero's Forge Cloth Helm Ornament

-- model 10601
UPDATE items SET herosforgemodel = 10601 WHERE id = 87884; -- Violet Hero's Forge Cloth Chest Ornament

-- model 10602
UPDATE items SET herosforgemodel = 10602 WHERE id = 87885; -- Violet Hero's Forge Cloth Arms Ornament

-- model 10603
UPDATE items SET herosforgemodel = 10603 WHERE id = 87886; -- Violet Hero's Forge Cloth Wrist Ornament

-- model 10604
UPDATE items SET herosforgemodel = 10604 WHERE id = 87887; -- Violet Hero's Forge Cloth Hands Ornament

-- model 10605
UPDATE items SET herosforgemodel = 10605 WHERE id = 87888; -- Violet Hero's Forge Cloth Legs Ornament

-- model 10606
UPDATE items SET herosforgemodel = 10606 WHERE id = 87889; -- Violet Hero's Forge Cloth Feet Ornament

-- model 10607
UPDATE items SET herosforgemodel = 10607 WHERE id = 87890; -- Violet Hero's Forge Cloth Robe Ornament

-- model 10700
UPDATE items SET herosforgemodel = 10700 WHERE id = 87869; -- Violet Hero's Forge Chain Helm Ornament

-- model 10701
UPDATE items SET herosforgemodel = 10701 WHERE id = 87870; -- Violet Hero's Forge Chain Chest Ornament

-- model 10702
UPDATE items SET herosforgemodel = 10702 WHERE id = 87871; -- Violet Hero's Forge Chain Arms Ornament

-- model 10703
UPDATE items SET herosforgemodel = 10703 WHERE id = 87872; -- Violet Hero's Forge Chain Wrist Ornament

-- model 10704
UPDATE items SET herosforgemodel = 10704 WHERE id = 87873; -- Violet Hero's Forge Chain Hands Ornament

-- model 10705
UPDATE items SET herosforgemodel = 10705 WHERE id = 87874; -- Violet Hero's Forge Chain Legs Ornament

-- model 10706
UPDATE items SET herosforgemodel = 10706 WHERE id = 87875; -- Violet Hero's Forge Chain Feet Ornament

-- model 10800
UPDATE items SET herosforgemodel = 10800 WHERE id = 87891; -- Beryl Hero's Forge Plate Helm Ornament

-- model 10801
UPDATE items SET herosforgemodel = 10801 WHERE id = 87892; -- Beryl Hero's Forge Plate Chest Ornament

-- model 10802
UPDATE items SET herosforgemodel = 10802 WHERE id = 87893; -- Beryl Hero's Forge Plate Arms Ornament

-- model 10803
UPDATE items SET herosforgemodel = 10803 WHERE id = 87894; -- Beryl Hero's Forge Plate Wrist Ornament

-- model 10804
UPDATE items SET herosforgemodel = 10804 WHERE id = 87895; -- Beryl Hero's Forge Plate Hands Ornament

-- model 10805
UPDATE items SET herosforgemodel = 10805 WHERE id = 87896; -- Beryl Hero's Forge Plate Legs Ornament

-- model 10806
UPDATE items SET herosforgemodel = 10806 WHERE id = 87897; -- Beryl Hero's Forge Plate Feet Ornament

-- model 10900
UPDATE items SET herosforgemodel = 10900 WHERE id = 87905; -- Beryl Hero's Forge Leather Helm Ornament

-- model 10901
UPDATE items SET herosforgemodel = 10901 WHERE id = 87906; -- Beryl Hero's Forge Leather Chest Ornament

-- model 10902
UPDATE items SET herosforgemodel = 10902 WHERE id = 87907; -- Beryl Hero's Forge Leather Arms Ornament

-- model 10903
UPDATE items SET herosforgemodel = 10903 WHERE id = 87908; -- Beryl Hero's Forge Leather Wrist Ornament

-- model 10904
UPDATE items SET herosforgemodel = 10904 WHERE id = 87909; -- Beryl Hero's Forge Leather Hands Ornament

-- model 10905
UPDATE items SET herosforgemodel = 10905 WHERE id = 87910; -- Beryl Hero's Forge Leather Legs Ornament

-- model 10906
UPDATE items SET herosforgemodel = 10906 WHERE id = 87911; -- Beryl Hero's Forge Leather Feet Ornament

-- model 11000
UPDATE items SET herosforgemodel = 11000 WHERE id = 87912; -- Beryl Hero's Forge Cloth Helm Ornament

-- model 11001
UPDATE items SET herosforgemodel = 11001 WHERE id = 87913; -- Beryl Hero's Forge Cloth Chest Ornament

-- model 11002
UPDATE items SET herosforgemodel = 11002 WHERE id = 87914; -- Beryl Hero's Forge Cloth Arms Ornament

-- model 11003
UPDATE items SET herosforgemodel = 11003 WHERE id = 87915; -- Beryl Hero's Forge Cloth Wrist Ornament

-- model 11004
UPDATE items SET herosforgemodel = 11004 WHERE id = 87916; -- Beryl Hero's Forge Cloth Hands Ornament

-- model 11005
UPDATE items SET herosforgemodel = 11005 WHERE id = 87917; -- Beryl Hero's Forge Cloth Legs Ornament

-- model 11006
UPDATE items SET herosforgemodel = 11006 WHERE id = 87918; -- Beryl Hero's Forge Cloth Feet Ornament

-- model 11007
UPDATE items SET herosforgemodel = 11007 WHERE id = 87919; -- Beryl Hero's Forge Cloth Robe Ornament

-- model 11100
UPDATE items SET herosforgemodel = 11100 WHERE id = 87898; -- Beryl Hero's Forge Chain Helm Ornament

-- model 11101
UPDATE items SET herosforgemodel = 11101 WHERE id = 87899; -- Beryl Hero's Forge Chain Chest Ornament

-- model 11102
UPDATE items SET herosforgemodel = 11102 WHERE id = 87900; -- Beryl Hero's Forge Chain Arms Ornament

-- model 11103
UPDATE items SET herosforgemodel = 11103 WHERE id = 87901; -- Beryl Hero's Forge Chain Wrist Ornament

-- model 11104
UPDATE items SET herosforgemodel = 11104 WHERE id = 87902; -- Beryl Hero's Forge Chain Hands Ornament

-- model 11105
UPDATE items SET herosforgemodel = 11105 WHERE id = 87903; -- Beryl Hero's Forge Chain Legs Ornament

-- model 11106
UPDATE items SET herosforgemodel = 11106 WHERE id = 87904; -- Beryl Hero's Forge Chain Feet Ornament

-- model 11200
UPDATE items SET herosforgemodel = 11200 WHERE id = 87920; -- Auburn Hero's Forge Plate Helm Ornament

-- model 11201
UPDATE items SET herosforgemodel = 11201 WHERE id = 87921; -- Auburn Hero's Forge Plate Chest Ornament

-- model 11202
UPDATE items SET herosforgemodel = 11202 WHERE id = 87922; -- Auburn Hero's Forge Plate Arms Ornament

-- model 11203
UPDATE items SET herosforgemodel = 11203 WHERE id = 87923; -- Auburn Hero's Forge Plate Wrist Ornament

-- model 11204
UPDATE items SET herosforgemodel = 11204 WHERE id = 87924; -- Auburn Hero's Forge Plate Hands Ornament

-- model 11205
UPDATE items SET herosforgemodel = 11205 WHERE id = 87925; -- Auburn Hero's Forge Plate Legs Ornament

-- model 11206
UPDATE items SET herosforgemodel = 11206 WHERE id = 87926; -- Auburn Hero's Forge Plate Feet Ornament

-- model 11300
UPDATE items SET herosforgemodel = 11300 WHERE id = 87934; -- Auburn Hero's Forge Leather Helm Ornament

-- model 11301
UPDATE items SET herosforgemodel = 11301 WHERE id = 87935; -- Auburn Hero's Forge Leather Chest Ornament

-- model 11302
UPDATE items SET herosforgemodel = 11302 WHERE id = 87936; -- Auburn Hero's Forge Leather Arms Ornament

-- model 11303
UPDATE items SET herosforgemodel = 11303 WHERE id = 87937; -- Auburn Hero's Forge Leather Wrist Ornament

-- model 11304
UPDATE items SET herosforgemodel = 11304 WHERE id = 87938; -- Auburn Hero's Forge Leather Hands Ornament

-- model 11305
UPDATE items SET herosforgemodel = 11305 WHERE id = 87939; -- Auburn Hero's Forge Leather Legs Ornament

-- model 11306
UPDATE items SET herosforgemodel = 11306 WHERE id = 87940; -- Auburn Hero's Forge Leather Feet Ornament

-- model 11400
UPDATE items SET herosforgemodel = 11400 WHERE id = 87941; -- Auburn Hero's Forge Cloth Helm Ornament

-- model 11401
UPDATE items SET herosforgemodel = 11401 WHERE id = 87942; -- Auburn Hero's Forge Cloth Chest Ornament

-- model 11402
UPDATE items SET herosforgemodel = 11402 WHERE id = 87943; -- Auburn Hero's Forge Cloth Arms Ornament

-- model 11403
UPDATE items SET herosforgemodel = 11403 WHERE id = 87944; -- Auburn Hero's Forge Cloth Wrist Ornament

-- model 11404
UPDATE items SET herosforgemodel = 11404 WHERE id = 87945; -- Auburn Hero's Forge Cloth Hands Ornament

-- model 11405
UPDATE items SET herosforgemodel = 11405 WHERE id = 87946; -- Auburn Hero's Forge Cloth Legs Ornament

-- model 11406
UPDATE items SET herosforgemodel = 11406 WHERE id = 87947; -- Auburn Hero's Forge Cloth Feet Ornament

-- model 11407
UPDATE items SET herosforgemodel = 11407 WHERE id = 87948; -- Auburn Hero's Forge Cloth Robe Ornament

-- model 11500
UPDATE items SET herosforgemodel = 11500 WHERE id = 87927; -- Auburn Hero's Forge Chain Helm Ornament

-- model 11501
UPDATE items SET herosforgemodel = 11501 WHERE id = 87928; -- Auburn Hero's Forge Chain Chest Ornament

-- model 11502
UPDATE items SET herosforgemodel = 11502 WHERE id = 87929; -- Auburn Hero's Forge Chain Arms Ornament

-- model 11503
UPDATE items SET herosforgemodel = 11503 WHERE id = 87930; -- Auburn Hero's Forge Chain Wrist Ornament

-- model 11504
UPDATE items SET herosforgemodel = 11504 WHERE id = 87931; -- Auburn Hero's Forge Chain Hands Ornament

-- model 11505
UPDATE items SET herosforgemodel = 11505 WHERE id = 87932; -- Auburn Hero's Forge Chain Legs Ornament

-- model 11506
UPDATE items SET herosforgemodel = 11506 WHERE id = 87933; -- Auburn Hero's Forge Chain Feet Ornament

-- model 11700
UPDATE items SET herosforgemodel = 11700 WHERE id = 85414; -- Jack O' Lantern Head Ornament

-- model 11800
UPDATE items SET herosforgemodel = 11800 WHERE id = 85413; -- Pumpkin Cap Ornament

-- model 11900
UPDATE items SET herosforgemodel = 11900 WHERE id = 85415; -- Skull Head Ornament

-- model 12000
UPDATE items SET herosforgemodel = 12000 WHERE id = 85412; -- Mummy Head Ornament

-- model 12100
UPDATE items SET herosforgemodel = 12100 WHERE id = 85416; -- Witch's Hat Ornament

-- model 12300
UPDATE items SET herosforgemodel = 12300 WHERE id = 85418; -- Red Santug Cap Ornament

-- model 12400
UPDATE items SET herosforgemodel = 12400 WHERE id = 85420; -- Santug Helper's Cap Ornament

-- model 12500
UPDATE items SET herosforgemodel = 12500 WHERE id = 85423; -- Glowing Nose Ornament

-- model 12600
UPDATE items SET herosforgemodel = 12600 WHERE id = 85424; -- Top Hat Ornament

-- model 12700
UPDATE items SET herosforgemodel = 12700 WHERE id = 85425; -- Snowman Head Ornament

-- model 12800
UPDATE items SET herosforgemodel = 12800 WHERE id = 85422; -- Reindeer Antlers Ornament

-- model 12900
UPDATE items SET herosforgemodel = 12900 WHERE id = 85421; -- Santug Helper's Striped Cap Ornament

-- model 13000
UPDATE items SET herosforgemodel = 13000 WHERE id = 85419; -- Green Santug Cap Ornament

-- model 13100
UPDATE items SET herosforgemodel = 13100 WHERE id = 85426; -- Helm of the Evil Eye Ornament

-- model 13200
UPDATE items SET herosforgemodel = 13200 WHERE id = 85427; -- Unspoken Mask Ornament

-- model 13300
UPDATE items SET herosforgemodel = 13300 WHERE id = 85417; -- Flaming Wizard Hat Ornament

-- model 13400
UPDATE items SET herosforgemodel = 13400 WHERE id = 85428; -- Black Skull Wizard Hat Ornament

-- model 13500
UPDATE items SET herosforgemodel = 13500 WHERE id = 85429; -- Purple Skull Wizard Hat Ornament

-- model 13600
UPDATE items SET herosforgemodel = 13600 WHERE id = 85430; -- Green Leaf Wizard Hat Ornament

-- model 13700
UPDATE items SET herosforgemodel = 13700 WHERE id = 85431; -- Hero's Forge Floppy Wizard Hat Ornament

-- model 13800
UPDATE items SET herosforgemodel = 13800 WHERE id = 85432; -- Skull Charm Wizard Hat Ornament

-- model 13900
UPDATE items SET herosforgemodel = 13900 WHERE id = 85433; -- Traditional Wizard Hat Ornament

-- model 14000
UPDATE items SET herosforgemodel = 14000 WHERE id = 85434; -- Ebon Wizard Hat Ornament

-- model 14100
UPDATE items SET herosforgemodel = 14100 WHERE id = 85437; -- Beryl Wizard Hat Ornament

-- model 14200
UPDATE items SET herosforgemodel = 14200 WHERE id = 85436; -- Violet Wizard Hat Ornament

-- model 14300
UPDATE items SET herosforgemodel = 14300 WHERE id = 85435; -- Viridian Wizard Hat Ornament

-- model 14400
UPDATE items SET herosforgemodel = 14400 WHERE id = 85438; -- Auburn Wizard Hat Ornament

-- model 14500
UPDATE items SET herosforgemodel = 14500 WHERE id = 85440; -- Grizzly Bear Hat Ornament

-- model 14600
UPDATE items SET herosforgemodel = 14600 WHERE id = 85441; -- Polar Bear Hat Ornament

-- model 14700
UPDATE items SET herosforgemodel = 14700 WHERE id = 85442; -- Black Bear Hat Ornament

-- model 14800
UPDATE items SET herosforgemodel = 14800 WHERE id = 85443; -- Panda Bear Hat Ornament

-- model 14900
UPDATE items SET herosforgemodel = 14900 WHERE id = 85439; -- Hero's Forge Pointy Wizard Hat Ornament

-- model 15100
UPDATE items SET herosforgemodel = 15100 WHERE id = 85445; -- Fox Hat Ornament

-- model 15200
UPDATE items SET herosforgemodel = 15200 WHERE id = 85444; -- Gray Wolf Hat Ornament

-- model 15300
UPDATE items SET herosforgemodel = 15300 WHERE id = 85446; -- Rabbit Hat Ornament

-- model 15400
UPDATE items SET herosforgemodel = 15400 WHERE id = 85448; -- Shamrock Bowler Hat Ornament

-- model 15500
UPDATE items SET herosforgemodel = 15500 WHERE id = 85447; -- Shamrock Top Hat Ornament

-- model 15800
UPDATE items SET herosforgemodel = 15800 WHERE id = 77977; -- Erollisi's Twin Hearts Head Ornament

-- model 15900
UPDATE items SET herosforgemodel = 15900 WHERE id = 77975; -- Erollisi's Arrow Head Ornament

-- model 16000
UPDATE items SET herosforgemodel = 16000 WHERE id = 77978; -- Innoruuk's Black Rose Head Ornament

-- model 16100
UPDATE items SET herosforgemodel = 16100 WHERE id = 77976; -- Innoruuk's Black Arrow Head Ornament

-- model 20300
UPDATE items SET herosforgemodel = 20300 WHERE id = 81510; -- Golden Hero Cloth Helm Ornament

-- model 20301
UPDATE items SET herosforgemodel = 20301 WHERE id = 81511; -- Golden Hero Cloth Chest Ornament

-- model 20302
UPDATE items SET herosforgemodel = 20302 WHERE id = 81512; -- Golden Hero Cloth Arms Ornament

-- model 20303
UPDATE items SET herosforgemodel = 20303 WHERE id = 81513; -- Golden Hero Cloth Wrist Ornament

-- model 20304
UPDATE items SET herosforgemodel = 20304 WHERE id = 81514; -- Golden Hero Cloth Hands Ornament

-- model 20305
UPDATE items SET herosforgemodel = 20305 WHERE id = 81515; -- Golden Hero Cloth Legs Ornament

-- model 20306
UPDATE items SET herosforgemodel = 20306 WHERE id = 81516; -- Golden Hero Cloth Feet Ornament

-- model 20400
UPDATE items SET herosforgemodel = 20400 WHERE id = 81518; -- Golden Hero Leather Helm Ornament

-- model 20401
UPDATE items SET herosforgemodel = 20401 WHERE id = 81519; -- Golden Hero Leather Chest Ornament

-- model 20402
UPDATE items SET herosforgemodel = 20402 WHERE id = 81520; -- Golden Hero Leather Arms Ornament

-- model 20403
UPDATE items SET herosforgemodel = 20403 WHERE id = 81521; -- Golden Hero Leather Wrist Ornament

-- model 20404
UPDATE items SET herosforgemodel = 20404 WHERE id = 81522; -- Golden Hero Leather Hands Ornament

-- model 20405
UPDATE items SET herosforgemodel = 20405 WHERE id = 81523; -- Golden Hero Leather Legs Ornament

-- model 20406
UPDATE items SET herosforgemodel = 20406 WHERE id = 81524; -- Golden Hero Leather Feet Ornament

-- model 20500
UPDATE items SET herosforgemodel = 20500 WHERE id = 81525; -- Golden Hero Chain Helm Ornament

-- model 20501
UPDATE items SET herosforgemodel = 20501 WHERE id = 81526; -- Golden Hero Chain Chest Ornament

-- model 20502
UPDATE items SET herosforgemodel = 20502 WHERE id = 81527; -- Golden Hero Chain Arms Ornament

-- model 20503
UPDATE items SET herosforgemodel = 20503 WHERE id = 81528; -- Golden Hero Chain Wrist Ornament

-- model 20504
UPDATE items SET herosforgemodel = 20504 WHERE id = 81529; -- Golden Hero Chain Hands Ornament

-- model 20505
UPDATE items SET herosforgemodel = 20505 WHERE id = 81530; -- Golden Hero Chain Legs Ornament

-- model 20506
UPDATE items SET herosforgemodel = 20506 WHERE id = 81531; -- Golden Hero Chain Feet Ornament

-- model 20600
UPDATE items SET herosforgemodel = 20600 WHERE id = 81532; -- Golden Hero Plate Helm Ornament

-- model 20601
UPDATE items SET herosforgemodel = 20601 WHERE id = 81533; -- Golden Hero Plate Chest Ornament

-- model 20602
UPDATE items SET herosforgemodel = 20602 WHERE id = 81534; -- Golden Hero Plate Arms Ornament

-- model 20603
UPDATE items SET herosforgemodel = 20603 WHERE id = 81535; -- Golden Hero Plate Wrist Ornament

-- model 20604
UPDATE items SET herosforgemodel = 20604 WHERE id = 81536; -- Golden Hero Plate Hands Ornament

-- model 20605
UPDATE items SET herosforgemodel = 20605 WHERE id = 81537; -- Golden Hero Plate Legs Ornament

-- model 20606
UPDATE items SET herosforgemodel = 20606 WHERE id = 81538; -- Golden Hero Plate Feet Ornament

