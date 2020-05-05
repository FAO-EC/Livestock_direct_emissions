## SCRIPT FOR EMISSIONS ESTIMATION
## NATIONAL LEVEL
## GANADERIA CLIMATICAMENTE INTELIGENTE
## 2019

## ARMANDO RIVERA
## armando.d.rivera@outlook.com

## BASED ON
## GLEAM 2.0 (FEB. 2017)
## http://www.fao.org/gleam/resources/es/

## The script automate the formulas from
## the GLEAM model for cattle production
##
## The results show:
## production estimation in liters and kg of meat
## Direct emissions:
## CH4 (methane) emissions from enteric fermentation
## CH4 emissions from manure management
## N2O (nitrous oxide) emissions from manure management
## N2O emissions from manure in pastures
## The emissions are converted to CO2-eq

## INITIALS
## AF = ADULT FEMALES (VACAS)
## AM = ADULT MALES (TOROS)
## YF = YOUNG FEMALES (VACONAS)
## YM = YOUNG MALES (TORETES)
## MF = MEAT FEMALES (HEMBRAS DE CARNE)
## MM = MEAT MALES (MACHOS DE CARNE)
## OT = OTHER CATEGORIES ANIMALS 
## (OTRAS CATEGORIAS DE ANIMALES 
## FUERA DE LAS VACAS)

########################################
## LIBRARIES
########################################

library(dplyr)
library(raster)
library(rgdal)

########################################
##FUNCTIONS
########################################

ecuador_emissions = function(
  
  ## CSV FILES
  ## DIGESTIBILITY (PERCENTAGE)
  ## PROTEIN NITROGEN (gN/kg DRY MATTER)  
  ## MIN = MINIMUM (LITERATURE REVIEW)
  ## MAX = MAXIMUM (LITERATURE REVIEW)
  ## 
  ## IF LAB ANALYSIS IS USED, PUT THE
  ## SAME VALUE IN MAX AND MIN
  national_data, #csv herd and manure management data
  main_pasture_list_marginal_milk, #csv main pasture marginal milk
  main_pasture_list_marginal_meat, #csv main pasture marginal meat
  main_pasture_list_mercantil_milk, #csv main pasture mercantil milk
  main_pasture_list_mercantil_meat, #csv main pasture mercantil meat
  main_pasture_list_combinado_milk, #csv main pasture combinado milk
  main_pasture_list_combinado_meat, #csv main pasture combinado meat
  main_pasture_list_empresarial_milk, #csv main pasture empresarial milk
  main_pasture_list_empresarial_meat, #csv main pasture empresarial meat
  diet_list_marginal_milk, 
  diet_list_marginal_meat,
  diet_list_mercantil_milk,
  diet_list_mercantil_meat,
  diet_list_combinado_milk,
  diet_list_combinado_meat,
  diet_list_empresarial_milk,
  diet_list_empresarial_meat
){

  ########################################
  ## GLEAM VARIABLES
  ########################################
  
  ##PRODUCTIVE SYSTEMS LIST BY PRODUCTION
  ##TYPE
  estrato_list = c("COMBINADO_CARNE","COMBINADO_LECHE",
                   "EMPRESARIAL_CARNE","EMPRESARIAL_LECHE",
                   "MARGINAL_CARNE","MARGINAL_LECHE",
                   "MERCANTIL_CARNE","MERCANTIL_LECHE")

  ##GLW FILE 
  ##RASTER WITH POTENTIAL LIVESTOCK DISTRIBUTION 
  glw_file_name = "ecuador_glw.tif"
  
  ##TEMPLATE WITH ZERO DATA
  base_data = read.csv("input\\base_data.csv")
  
  ########################################
  ##CALCULATIONS
  ########################################
  
  ##MATRIX GENERATION FROM NATIONAL DATA
  year = national_data
  
  ##COLUMN WITH CERO VALUES
  year$CODE=0

  ##CODE ASSIGNATION
  ##COSTA = 1000
  ##SIERRA = 2000
  ##AMAZONIA = 3000
  for (yearj in 1:nrow(year)) {
    if(year[yearj,"REGION"] == "COSTA"){
      year[yearj,"CODE"] = 1000
    } else if (year[yearj,"REGION"] == "SIERRA"){
      year[yearj,"CODE"] = 2000
    } else if (year[yearj,"REGION"] == "AMAZONIA"){
      year[yearj,"CODE"] = 3000
    }
  }
  
  ##RESULTS DIRECTORY
  dir.create("results")
  
  ##ASSIGN VARIABLES ACCORDING TO PRODUCTIVE
  ##SYSTEM AND PRODUCTION TYPE
  for (h in estrato_list) {
    if(h == "COMBINADO_CARNE"){
      hestrato = "COMBINADO"
      hproducto = "Carne"
      prov_code_file_name = "combinado.tif"
    } else  if(h == "COMBINADO_LECHE"){
      hestrato = "COMBINADO"
      hproducto = "Leche"
      prov_code_file_name = "combinado.tif"
    } else  if(h == "EMPRESARIAL_CARNE"){
      hestrato = "EMPRESARIAL" 
      hproducto = "Carne"
      prov_code_file_name = "empresarial.tif"
    } else  if(h == "EMPRESARIAL_LECHE"){
      hestrato = "EMPRESARIAL" 
      hproducto = "Leche"
      prov_code_file_name = "empresarial.tif"
    } else  if(h == "MARGINAL_CARNE"){
      hestrato = "MARGINAL"
      hproducto = "Carne"
      prov_code_file_name = "marginal.tif"
    } else  if(h == "MARGINAL_LECHE"){
      hestrato = "MARGINAL"
      hproducto = "Leche"
      prov_code_file_name = "marginal.tif"
    } else  if(h == "MERCANTIL_CARNE"){
      hestrato = "MERCANTIL"
      hproducto = "Carne"
      prov_code_file_name = "mercantil.tif"
    } else  if(h == "MERCANTIL_LECHE"){
      hestrato = "MERCANTIL"
      hproducto = "Leche"
      prov_code_file_name = "mercantil.tif"
    }
    
   
    ##BASE DATA PROCESSING
    base1 = base_data
    base_filter = year[year$ESTRATO== hestrato & year$PRODUCTO==hproducto,]
    base1[match(base_filter$CODE, base1$CODE),] = base_filter
    base1$PRODUCTO=hproducto
    base1$ESTRATO=hestrato
    for (i in 1:nrow(base1)) {
      if(base1[i,"CODE"] == 1000){
        base1[i,"REGION"] = "COSTA"
      } else if(base1[i,"CODE"] == 2000){
        base1[i,"REGION"] = "SIERRA"
      } else if(base1[i,"CODE"] == 3000){
        base1[i,"REGION"] = "AMAZONIA"
      }
    }
    parameters_filename = base1

    ##DIRECTORIES
    path_name = paste("results\\",h, sep="")
    dir.create(path_name)
    
    results_path = paste(path_name,"\\herd_track\\", sep = "")
    feed_path = paste(path_name,"\\feed_track\\", sep = "")
    
    results_path2 = paste(path_name,"\\system_track\\", sep = "")
    results_ge_feedintake = paste(path_name,"\\system_track\\GE_feedintake\\", sep = "")
    results_methame_emss = paste(path_name,"\\system_track\\Methane_emss\\", sep = "")
    results_mcf = paste(path_name,"\\system_track\\MCF\\", sep = "")
    results_n2o = paste(path_name, "\\system_track\\N2O_emss\\", sep = "")
    results_excretion = paste(results_n2o, "N_excretion\\", sep = "")
    results_direct_N2O = paste(results_n2o, "direct_N2O\\", sep = "")
    results_indirect_N2O = paste (results_n2o, "indirect_N2O\\", sep = "")
    
    data_path_systemtrack = paste(path_name,"\\system_track\\", sep = "")
    data_path_herdtrack = paste(path_name,"\\herd_track\\", sep = "")
    table_path = paste(path_name,"\\results_tables\\", sep = "")
    
    dir.create(results_path)
    dir.create(feed_path)
    dir.create(results_path2)
    dir.create(results_ge_feedintake)
    dir.create(results_methame_emss)
    dir.create(results_mcf)
    dir.create(results_n2o)
    dir.create(results_excretion)
    dir.create(results_direct_N2O)
    dir.create(results_indirect_N2O)
    dir.create(table_path)
    
    # SET THE PARAMETERS
    zone_rst = raster(paste("input\\",prov_code_file_name, sep = ""))
    in_value_rst = raster(paste("input\\",glw_file_name, sep = "")) 
    parameters= parameters_filename
    
    #Generate a raster with cero values
    cero_value_fun <- function(x) {(x>0) * 0}
    cero_value_raster <- calc(zone_rst, cero_value_fun, progress='text')
    
    one_value_fun <- function(x) {(x>0)}
    one_value_raster <- calc(zone_rst, one_value_fun, progress='text')
    
    ########################################
    ## HERD TRACK
    ########################################
    ## INITIALSL FROM GLEAM 2.0 (FEB. 2017)
    ## http://www.fao.org/gleam/resources/es/
    
    #construct the data table of parameters
    dairy = zonal(in_value_rst, zone_rst, 'sum')
    colnames(dairy)=c("CODE", "GLW")
    dairy=merge(dairy, parameters, by = "CODE", all = TRUE)
    dairy[is.na(dairy)] <- 0
    herd = zonal(in_value_rst, zone_rst, 'sum')
    colnames(herd)=c("CODE", "GLW")
    
    ## SEE PAGE 9 (GLEAM 2.0)
    ## AF = adult_females
    ## AM = adult_males
    ## YF = young_females
    ## YM = young_males
    
    
    
    ## DIET SUPPLIES TYPES
    ## -------------------------------------
    ##
    ## DIGESTIBILITY OF FOOD
    ## (PORCENTAJE)
    ##
    ## PROTEIN CONTENT
    ## (gN/kg Dry matter)  
    ## -------------------------------------
    ## Chapter 10: emissions from livestock and manure management. 
    ## IPCC guidelines for national greenhouse gas inventories.
    ## page 10.22
    
    ## Digestible energy percentage
    if(hestrato=="MARGINAL"){
      DE_percentage = 45
    } else if(hestrato=="MERCANTIL"){
      DE_percentage = 50
    } else if(hestrato=="COMBINADO"){
      DE_percentage = 55
    } else if(hestrato=="EMPRESARIAL"){
      DE_percentage = 60
    }
    
    ## estimated dietary net energy
    if(hestrato=="MARGINAL"){
      grow_nema = 3.5
    } else if(hestrato=="MERCANTIL"){
      grow_nema = 4.5
    } else if(hestrato=="COMBINADO"){
      grow_nema = 5.5
    } else if(hestrato=="EMPRESARIAL"){
      grow_nema = 6.5
    }
    
    ## Estimation of dry matter intake for mature dairy cows
    if(hproducto == "Leche"){
      dairy <- transform(dairy, DMI_AF = ((5.4*AFKG)/500)/((100-DE_percentage)/100))
      
    }
    
    ## Estimation of dry matter intake for growing and finishing cattle
    if(hproducto == "Carne"){
      dairy <- transform(dairy, DMI_AF = AFKG^0.75*((0.0119*grow_nema^2+0.1938)/grow_nema))
    }
    
    ## Growing animals
    dairy <- transform(dairy, DMI_YF = MFSKG^0.75*((0.2444*grow_nema-0.0111*grow_nema^2-0.472)/grow_nema))
    dairy <- transform(dairy, DMI_YM = MMSKG^0.75*((0.2444*grow_nema-0.0111*grow_nema^2-0.472)/grow_nema))
    dairy <- transform(dairy, DMI_female_calves = CKG^0.75*((0.2444*grow_nema-0.0111*grow_nema^2-0.472)/grow_nema))
    dairy <- transform(dairy, DMI_male_calves = CKG^0.75*((0.2444*grow_nema-0.0111*grow_nema^2-0.472)/grow_nema))
    
    ## AM
    dairy <- transform(dairy, DMI_AM=AMKG^0.75*((0.0119*grow_nema^2+0.1938)/grow_nema))
    
    ## Avergae OT (OTHER CATEGORIES NO AF)
    dairy <- transform(dairy, DMI_OT = (DMI_female_calves+DMI_male_calves+DMI_YM+DMI_YF+DMI_AM)/5)
    
    ## DRY MATTER DIET LIST
    if(h == "COMBINADO_CARNE"){
      diet_matrix = diet_list_combinado_meat
      pasture_matrix = main_pasture_list_combinado_meat
    } else  if(h == "COMBINADO_LECHE"){
      diet_matrix = diet_list_combinado_milk
      pasture_matrix = main_pasture_list_combinado_milk
    } else  if(h == "EMPRESARIAL_CARNE"){
      diet_matrix = diet_list_empresarial_meat
      pasture_matrix = main_pasture_list_empresarial_meat
    } else  if(h == "EMPRESARIAL_LECHE"){
      diet_matrix = diet_list_empresarial_milk
      pasture_matrix = main_pasture_list_empresarial_milk
    } else  if(h == "MARGINAL_CARNE"){
      diet_matrix = diet_list_marginal_meat
      pasture_matrix = main_pasture_list_marginal_meat
    } else  if(h == "MARGINAL_LECHE"){
      diet_matrix = diet_list_marginal_milk
      pasture_matrix = main_pasture_list_marginal_milk
    } else  if(h == "MERCANTIL_CARNE"){
      diet_matrix = diet_list_mercantil_meat
      pasture_matrix = main_pasture_list_mercantil_meat
    } else  if(h == "MERCANTIL_LECHE"){
      diet_matrix = diet_list_mercantil_milk
      pasture_matrix = main_pasture_list_mercantil_milk
    }
    
    diet_matrix$ms_AF_costa = diet_matrix$adult_female_feed_costa_kg *(diet_matrix$dry_matter_percentage/100)
    diet_matrix$ms_OT_costa = diet_matrix$other_categories_feed_costa_kg *(diet_matrix$dry_matter_percentage/100)
    diet_matrix$ms_AF_sierra = diet_matrix$adult_female_feed_sierra_kg *(diet_matrix$dry_matter_percentage/100)
    diet_matrix$ms_OT_sierra = diet_matrix$other_categories_feed_sierra_kg *(diet_matrix$dry_matter_percentage/100)
    diet_matrix$ms_AF_amazonia = diet_matrix$adult_female_feed_amazonia_kg *(diet_matrix$dry_matter_percentage/100)
    diet_matrix$ms_OT_amazonia = diet_matrix$other_categories_feed_amazonia_kg *(diet_matrix$dry_matter_percentage/100)
    
    dairy[dairy$REGION=="COSTA","ms_AF_total"] = sum(diet_matrix$ms_AF_costa)
    dairy[dairy$REGION=="SIERRA","ms_AF_total"] = sum(diet_matrix$ms_AF_sierra)
    dairy[dairy$REGION=="AMAZONIA","ms_AF_total"] = sum(diet_matrix$ms_AF_amazonia)
    dairy[dairy$REGION=="COSTA","ms_OT_total"] = sum(diet_matrix$ms_OT_costa)
    dairy[dairy$REGION=="SIERRA","ms_OT_total"] = sum(diet_matrix$ms_OT_sierra)
    dairy[dairy$REGION=="AMAZONIA","ms_OT_total"] = sum(diet_matrix$ms_OT_amazonia)
    
    dairy <- transform(dairy, DMI_AF_direct_pasture =  ifelse((DMI_AF - ms_AF_total)<=0,0,DMI_AF - ms_AF_total))
    dairy <- transform(dairy, DMI_OT_direct_pasture =  ifelse((DMI_OT - ms_OT_total)<=0,0,DMI_OT - ms_OT_total))
    
    ## PASTURE FEEDING
    pasture_matrix$pasture_costa_d = pasture_matrix$digestibility_percentage * pasture_matrix$percentage_costa / 100
    pasture_matrix$pasture_sierra_d = pasture_matrix$digestibility_percentage * pasture_matrix$percentage_sierra / 100
    pasture_matrix$pasture_amazonia_d = pasture_matrix$digestibility_percentage * pasture_matrix$percentage_amazonia / 100
    pasture_matrix$pasture_costa_n = pasture_matrix$nitrogen_content * pasture_matrix$percentage_costa / 100
    pasture_matrix$pasture_sierra_n = pasture_matrix$nitrogen_content * pasture_matrix$percentage_sierra / 100
    pasture_matrix$pasture_amazonia_n = pasture_matrix$nitrogen_content * pasture_matrix$percentage_amazonia / 100
    
    ms_pasture_costa_d = ifelse(mean(pasture_matrix$pasture_costa_d) == 0, 0, mean(pasture_matrix$pasture_costa_d[pasture_matrix$pasture_costa_d!=0]))
    ms_pasture_sierra_d = ifelse(mean(pasture_matrix$pasture_sierra_d) == 0, 0, mean(pasture_matrix$pasture_sierra_d[pasture_matrix$pasture_sierra_d!=0]))
    ms_pasture_amazonia_d = ifelse(mean(pasture_matrix$pasture_amazonia_d) == 0, 0, mean(pasture_matrix$pasture_amazonia_d[pasture_matrix$pasture_amazonia_d!=0]))
    ms_pasture_costa_n = ifelse(mean(pasture_matrix$pasture_costa_n) == 0, 0, mean(pasture_matrix$pasture_costa_n[pasture_matrix$pasture_costa_n!=0]))
    ms_pasture_sierra_n = ifelse(mean(pasture_matrix$pasture_sierra_n) == 0, 0, mean(pasture_matrix$pasture_sierra_n[pasture_matrix$pasture_sierra_n!=0]))
    ms_pasture_amazonia_n = ifelse(mean(pasture_matrix$pasture_amazonia_n) == 0, 0, mean(pasture_matrix$pasture_amazonia_n[pasture_matrix$pasture_amazonia_n!=0]))
    
    diet_matrix = rbind(diet_matrix, c(NA, NA, ms_pasture_costa_d, ms_pasture_costa_n,
                                       NA, NA, NA, NA, NA, NA, NA, 
                                       dairy[dairy$REGION=="COSTA","DMI_AF_direct_pasture"],
                                       dairy[dairy$REGION=="COSTA","DMI_OT_direct_pasture"],
                                       0,0,0,0))
    diet_matrix = rbind(diet_matrix, c(NA, NA, ms_pasture_sierra_d, ms_pasture_sierra_n,
                                       NA, NA, NA, NA, NA, NA, NA,0,0,
                                       dairy[dairy$REGION=="SIERRA","DMI_AF_direct_pasture"],
                                       dairy[dairy$REGION=="SIERRA","DMI_OT_direct_pasture"],
                                       0,0))
    diet_matrix = rbind(diet_matrix, c(NA, NA, ms_pasture_amazonia_d, ms_pasture_amazonia_n,
                                       NA, NA, NA, NA, NA, NA, NA,0,0,0,0,
                                       dairy[dairy$REGION=="AMAZONIA","DMI_AF_direct_pasture"],
                                       dairy[dairy$REGION=="AMAZONIA","DMI_OT_direct_pasture"]))
    
    
    if(sum(as.numeric(diet_matrix$ms_AF_costa)) == 0){
      diet_matrix$AF_COSTA = 0
    }else{
      diet_matrix$AF_COSTA = diet_matrix$ms_AF_costa/sum(as.numeric(diet_matrix$ms_AF_costa))*100
    }
    
    if(sum(as.numeric(diet_matrix$ms_OT_costa)) == 0){
      diet_matrix$OT_COSTA = 0
    }else{
      diet_matrix$OT_COSTA = diet_matrix$ms_OT_costa/sum(as.numeric(diet_matrix$ms_OT_costa))*100
    }
    
    if(sum(as.numeric(diet_matrix$ms_AF_sierra)) == 0){
      diet_matrix$AF_SIERRA = 0
    }else{
      diet_matrix$AF_SIERRA = as.numeric(diet_matrix$ms_AF_sierra)/sum(as.numeric(diet_matrix$ms_AF_sierra))*100
    }
    
    if(sum(as.numeric(diet_matrix$ms_OT_sierra)) == 0){
      diet_matrix$OT_SIERRA = 0
    }else{
      diet_matrix$OT_SIERRA = as.numeric(diet_matrix$ms_OT_sierra)/sum(as.numeric(diet_matrix$ms_OT_sierra))*100
    }
    
    if(sum(as.numeric(diet_matrix$ms_AF_amazonia)) == 0){
      diet_matrix$AF_AMAZONIA = 0
    }else{
      diet_matrix$AF_AMAZONIA = as.numeric(diet_matrix$ms_AF_amazonia)/sum(as.numeric(diet_matrix$ms_AF_amazonia))*100
    }
    
    if(sum(as.numeric(diet_matrix$ms_OT_amazonia)) == 0){
      diet_matrix$OT_AMAZONIA = 0
    }else{
      diet_matrix$OT_AMAZONIA = as.numeric(diet_matrix$ms_OT_amazonia)/sum(as.numeric(diet_matrix$ms_OT_amazonia))*100
    }
    
    ## DIGESTIBILITY CALCULATION
    ## SEE PAGE 52 (GLEAM 2.0)
    diet_matrix$AFLCIDE_COSTA = diet_matrix$AF_COSTA*as.numeric(diet_matrix$digestibility_percentage)
    diet_matrix$OTLCIDE_COSTA = diet_matrix$OT_COSTA*as.numeric(diet_matrix$digestibility_percentage)
    diet_matrix$AFLCIN_COSTA = diet_matrix$AF_COSTA*as.numeric(diet_matrix$nitrogen_content)
    diet_matrix$OTLCIN_COSTA = diet_matrix$OT_COSTA*as.numeric(diet_matrix$nitrogen_content)
    
    diet_matrix$AFLCIDE_SIERRA = diet_matrix$AF_SIERRA*as.numeric(diet_matrix$digestibility_percentage)
    diet_matrix$OTLCIDE_SIERRA = diet_matrix$OT_SIERRA*as.numeric(diet_matrix$digestibility_percentage)
    diet_matrix$AFLCIN_SIERRA = diet_matrix$AF_SIERRA*as.numeric(diet_matrix$nitrogen_content)
    diet_matrix$OTLCIN_SIERRA = diet_matrix$OT_SIERRA*as.numeric(diet_matrix$nitrogen_content)
    
    diet_matrix$AFLCIDE_AMAZONIA = diet_matrix$AF_AMAZONIA*as.numeric(diet_matrix$digestibility_percentage)
    diet_matrix$OTLCIDE_AMAZONIA = diet_matrix$OT_AMAZONIA*as.numeric(diet_matrix$digestibility_percentage)
    diet_matrix$AFLCIN_AMAZONIA = diet_matrix$AF_AMAZONIA*as.numeric(diet_matrix$nitrogen_content)
    diet_matrix$OTLCIN_AMAZONIA = diet_matrix$OT_AMAZONIA*as.numeric(diet_matrix$nitrogen_content)
    
    ## FEED VARIABLES
    ## AVERAGE DIGESTIBILITY OF THE AF DIET
    ## (DIETDI)
    dairy[dairy$REGION=="COSTA","AFLCIDE"] = sum(diet_matrix$AFLCIDE_COSTA)/100
    dairy[dairy$REGION=="SIERRA","AFLCIDE"] = sum(diet_matrix$AFLCIDE_SIERRA)/100
    dairy[dairy$REGION=="AMAZONIA","AFLCIDE"] = sum(diet_matrix$AFLCIDE_AMAZONIA)/100

    ## AVERAGE DIGESTIBILITY OF THE OT DIET
    ## (DIETDI)
    dairy[dairy$REGION=="COSTA","OTLCIDE"] = sum(diet_matrix$OTLCIDE_COSTA)/100
    dairy[dairy$REGION=="SIERRA","OTLCIDE"] = sum(diet_matrix$OTLCIDE_SIERRA)/100
    dairy[dairy$REGION=="AMAZONIA","OTLCIDE"] = sum(diet_matrix$OTLCIDE_AMAZONIA)/100

    ## AVERAGE NITROGEN OF THE AF DIET
    ## (DIETNCONTENT)  
    dairy[dairy$REGION=="COSTA","AFLCIN"] = sum(diet_matrix$AFLCIN_COSTA)/100
    dairy[dairy$REGION=="SIERRA","AFLCIN"] = sum(diet_matrix$AFLCIN_SIERRA)/100
    dairy[dairy$REGION=="AMAZONIA","AFLCIN"] = sum(diet_matrix$AFLCIN_AMAZONIA)/100
    
    ## AVERAGE NITROGEN OF THE OT DIET
    ##(DIETNCONTENT)  
    dairy[dairy$REGION=="COSTA","OTLCIN"] = sum(diet_matrix$OTLCIN_COSTA)/100
    dairy[dairy$REGION=="SIERRA","OTLCIN"] = sum(diet_matrix$OTLCIN_SIERRA)/100
    dairy[dairy$REGION=="AMAZONIA","OTLCIN"] = sum(diet_matrix$OTLCIN_AMAZONIA)/100
    
    ## -------------------------------------
    ## HERD CALCULATIONS
    ## -------------------------------------
    ##
    ## 2.1.2.1 FEMALE SECTION
    ## SEE PAGE 13 (GLEAM 2.0)
    
    dairy <- transform(dairy, AFC = AFC_MONTHS / 12)# age first calving in years
    dairy <- transform(dairy, LACT_PER = LACT_PER_MONTHS * 30.4) # lactancy period in days
    
    dairy <- transform(dairy, AFIN = (RRF/ 100) * AF)
    dairy <- transform(dairy, AFX = AF*(DR2/100))
    dairy <- transform(dairy, AFEXIT = (AF * (ERF / 100))) 
    dairy <- transform(dairy, CFIN = AF * ((1 - (DR2 / 100)) * (FR / 100) + (RRF / 100)) * 0.5 * (1 - (DR1F / 100)))
    dairy <- transform(dairy, RFIN = AFIN / (95/100) / ((1 - (DR2 / 100))^AFC)) 
    dairy <- transform(dairy, MFIN = CFIN - RFIN)
    dairy <- transform(dairy, RFIN = ifelse((MFIN < 0),RFIN+MFIN,RFIN))
    dairy <- transform(dairy, RFEXIT = (((RRF / 100) * AF) / (95/100)) - AFIN)  
    dairy <- transform(dairy, RF = ((RFIN + AFIN) / 2))
    
    dairy <- transform(dairy, ASF = ifelse(AFC == 0, 0, (MFSKG - CKG) / (AFKG - CKG) * AFC))
    dairy <- transform(dairy, ASF1 = ifelse(ASF <= 0, 0, ASF)) 
    dairy <- transform(dairy, MFEXIT = MFIN * ((1 - (DR2 / 100))^ASF1))
    dairy <- transform(dairy, MF = (MFIN + MFEXIT) / 2)
    
    ## 2.1.2.2 MALE SECTION
    ## SEE PAGE 14 (GLEAM 2.0)
    dairy <- transform(dairy, AMX = AM * (DR2 / 100)) 
    dairy <- transform(dairy, RRM = ifelse(AFC == 0, 0, 1 / AFC))
    dairy <- transform(dairy, AMEXIT = (AM * ERM / 100))
    dairy <- transform(dairy, CMIN = AF * ((1 - (DR2 / 100)) * (FR / 100) + (RRF / 100)) * 0.5 * (1 - (DR1M / 100)))
    dairy <- transform(dairy, AMIN = ifelse(AFC == 0, 0, AM / AFC))
    dairy <- transform(dairy, RMIN = AMIN / ((1 - (DR2 / 100))^AFC))
    dairy <- transform(dairy, MMIN = CMIN - RMIN)
    dairy <- transform(dairy, RMIN = ifelse((MMIN < 0),RMIN+MMIN,RMIN))
    dairy <- transform(dairy, RM = ((RMIN + AMIN) / 2))
    
    dairy <- mutate(dairy, ASM = ifelse(AFC == 0, 0, (MMSKG - CKG) / (AMKG - CKG) * AFC))
    dairy <- mutate(dairy, ASM1 = ifelse(ASM <= 0, 0, ASM))
    dairy <- transform(dairy, MMEXIT = MMIN * ((1 - (DR2 / 100))^ASM1)) #checked
    dairy <- transform(dairy, MM = (MMIN + MMEXIT) / 2)
    
    dairy <- transform(dairy, MILK_YIELD_KG = MILK_YIELD * 1.032)
    
    ## 2.1.2.5 WEIGHT SECTION
    ## SEE PAGE 16 (GLEAM 2.0)
    dairy <- transform(dairy, MFKG = ifelse(MFSKG == 0, 0,(MFSKG - CKG) / 2 + CKG))
    dairy <- transform(dairy, MMKG = ifelse(MMSKG == 0, 0,(MMSKG - CKG) / 2 + CKG))
    dairy <- transform(dairy, RFKG = ifelse(AFKG == 0, 0,(AFKG - CKG) / 2 + CKG))
    dairy <- transform(dairy, RMKG = ifelse(AMKG == 0, 0,(AMKG - CKG) / 2 + CKG))
    dairy <- mutate(dairy, GROWF = ifelse(AFC == 0, 0, (AFKG - CKG) / (AFC * 365)))
    dairy <- mutate(dairy, GROWM = ifelse(AFC == 0, 0, (AMKG - CKG) / (AFC * 365)))
    dairy <- mutate(dairy, GROWF = ifelse(GROWF < 0, 0, GROWF)) 
    dairy <- mutate(dairy, GROWM = ifelse(GROWM < 0, 0, GROWM))
    
    ## -------------------------------------
    ## HERD PROJECTION
    ## -------------------------------------
    
    ## NEGATIVE VALUES CORRECTION
    dairy <- mutate(dairy, RF = ifelse(RF<0, 0, RF))
    dairy <- mutate(dairy, RM = ifelse(RM<0, 0, RM))
    dairy <- mutate(dairy, MF = ifelse(MF<0, 0, MF))
    dairy <- mutate(dairy, MM = ifelse(MM<0, 0, MM))
    
    ## ANIMAL DISTRIBUTION ACCORDING REPORTED
    ## WEIGHT
    ## -------------------------------------
    ## THE PREVIOS CALCULATIONS MAKE A HERD
    ## PROJECTION. 
    ## FOR THE CORRECTION 
    ## IT IS ASSUMED THAT AN AFKG (AF WEIGHT)
    ## EQUAL TO ZERO, IMPLIES THAT THERE IS NO
    ## AF IN THE HERD AND NO REPLACEMENT 
    ## ANIMALS. THEN, THE VALUE OF MF 
    ## (MEAT FEMALE) AND RF (REEPLACEMENT FEMALES)
    ## ARE ASSIGNED TO MF
    ##
    ## IT IS ASSUMED THAT AN MFSKG (MEAT FEMALE
    ## WEIGHT) EQUAL TO ZERO, IMPLIES THAT
    ## THERE ARE NO MEAT ANIMALS. THEN THE VALUE
    ## OF MF (MEAT FEMALES) AND RF (REEPLACEMENT FEMALES)
    ## ARE ASSIGNED TO RF
    ## -------------------------------------
    dairy <- mutate(dairy, MF = ifelse(AFKG == 0 & MFSKG > 0, MF + RF,MF))
    dairy <- mutate(dairy, RF = ifelse(AFKG == 0 & MFSKG > 0, 0, RF))
    dairy <- mutate(dairy, RF = ifelse(AFKG > 0 & MFSKG == 0, RF + MF, RF))
    dairy <- mutate(dairy, MF = ifelse(AFKG > 0 & MFSKG == 0, 0, MF))
    dairy <- mutate(dairy, MF = ifelse(AFKG == 0 & MFSKG == 0, 0, MF))
    dairy <- mutate(dairy, RF = ifelse(AFKG == 0 & MFSKG == 0, 0, RF))
    dairy <- mutate(dairy, MM = ifelse(AMKG == 0 & MMSKG > 0, MM + RM, MM))
    dairy <- mutate(dairy, RM = ifelse(AMKG == 0 & MMSKG > 0, 0, RM))
    dairy <- mutate(dairy, RM = ifelse(AMKG > 0 & MMSKG == 0, RM + MM, RM))
    dairy <- mutate(dairy, MM = ifelse(AMKG > 0 & MMSKG == 0, 0, MM))
    dairy <- mutate(dairy, RM = ifelse(AMKG == 0 & MMSKG == 0, 0, RM))
    dairy <- mutate(dairy, MM = ifelse(AMKG == 0 & MMSKG == 0, 0, MM))
                    
    ## CORRECTION WITH THE REAL NUMBER OF
    ## YOUNG ANIMALS REPORTED
    ## -------------------------------------
    ## THE INPUT DATA INCLUDE VALUES OF 
    ## YOUNG FEMALES (YF) AND YOUNG MALES
    ## (YM). THE DISTRIBUTION OF RF, RM, 
    ## MF, MM IS ASSIGNED TO THE SUM OF YF
    ## AND YM. 
    ## THIS CALCULATION DETERMINES HOW MANY
    ## ANIMALS BELONG TO EACH CATEGORY
    ## OF THE YOUNG ANIMALS IN THE FARM.
    ## -------------------------------------
    dairy <- transform(dairy, DAIRY = AF + AM + RF + RM + MF + MM)
    dairy <- mutate(dairy, AFratio = ifelse(GLW == 0, 0, AF / GLW))
    dairy <- mutate(dairy, AMratio = ifelse(GLW == 0, 0, AM / GLW))
    dairy <- mutate(dairy, MFratio = ifelse(GLW == 0|(RF+MF)==0, 0, MF * (YF+YM) / (RM+MM+RF+MF) / GLW))
    dairy <- mutate(dairy, RFratio = ifelse(GLW == 0|(RF+MF)==0, 0, RF * (YF+YM) / (RM+MM+RF+MF) / GLW))
    dairy <- mutate(dairy, MMratio = ifelse(GLW == 0|(RM+MM) ==0, 0, MM * (YF+YM) / (RM+MM+RF+MF) / GLW))
    dairy <- mutate(dairy, RMratio = ifelse(GLW == 0|(RM+MM)==0, 0, RM * (YF+YM) / (RM+MM+RF+MF) / GLW))
    
    ## MEAT ANIMALS EXIT
    ## SEE PAGE 14 (GLEAM 2.0)
    
    ## ADULT ANIMALS EXIT FOR MEAT
    dairy <- mutate(dairy, AFEXIT1 = ifelse(DAIRY==0, 0, AFEXIT))
    
    ## REEPLACEMENT ANIMALS EXIT FOR MEAT
    ## SEE PAGE 14 (GLEAM 2.0)
    dairy <- mutate(dairy, RFEXIT1 = ifelse((RF+MF)==0, 0, RFEXIT * (YF+YM) / (RM+MM+RF+MF)))
    dairy <- mutate(dairy, AMEXIT1 = ifelse(DAIRY==0, 0, AMEXIT))
    dairy <- mutate(dairy, MFEXIT1 = ifelse((RF+MF)==0, 0, MFEXIT * (YF+YM) / (RM+MM+RF+MF)))
    dairy <- mutate(dairy, MMEXIT1 = ifelse((RM+MM)==0, 0, MMEXIT * (YF+YM) / (RM+MM+RF+MF)))
 
    
    ## 9.1.1 MILK PRODUCTIONE
    ## LITERS
    ## SEE PAGE 99 (GLEAM 2.0)
    dairy <- mutate(dairy, Milk_production = MILK_YIELD * LACT_PER * AF)
    
    ## 9.1.2 MEAT PRODUCTION
    ## KG CARCASS
    ## SEE PAGE 99 (GLEAM 2.0)
    
    ## MEAT OF GROWING FEMALE ANIMALS
    dairy <- mutate(dairy, AFEXITKG = ifelse(AFEXIT1 <= 0, 0, (AFEXIT1 * AFKG * 0.5)))# AFSKG changed to MFDKG, D descarte
    dairy <- mutate(dairy, RFEXITKG = ifelse(RFEXIT1 <= 0, 0, (RFEXIT1 * RFKG * 0.5)))
    dairy <- mutate(dairy, Meat_production_FF = AFEXITKG + RFEXITKG) # 0.5 peso a la canal
    
    ##MEAT OF GROWING MALE ANIMALS
    dairy <- mutate(dairy, Meat_production_FM = ifelse(AMEXIT1 <= 0, 0, (AMEXIT1 * AMKG * 0.5)))
    
    ##MEAT OF SLAUGHTERED YOUNG ANIMALS
    dairy <- mutate(dairy, MFEXITKG = ifelse(MFEXIT1 <= 0, 0, (MFEXIT1 * MFKG * 0.5)))
    dairy <- mutate(dairy, MMEXITKG = ifelse(MMEXIT1 <= 0, 0, (MMEXIT1 * MMKG * 0.5)))
    dairy <- mutate(dairy, Meat_production_M = MFEXITKG + MMEXITKG) # 0.5 peso a la canal
    write.csv(dairy, file = paste(table_path, "dairy.csv",sep = ""))
    
    #Generate rasters from the ratios variables in relation with the GLW raster
    ratio_variables = c("AFratio","AMratio","RFratio","RMratio","MFratio","MMratio") 
    for(k1 in ratio_variables){
      k2 = substr(k1,1,nchar(k1)-5)
      variable_raster = cero_value_raster
      for (i in 1:nrow(dairy)){
        temp_code = dairy[i,"CODE"]
        temp_variable = dairy[i,k1]
        temp_zone_raster = calc(zone_rst,  function(x) {x== temp_code} )
        temp_zone_calculated_raster= temp_zone_raster * temp_variable
        temp_glw_calculated= temp_zone_calculated_raster * in_value_rst 
        variable_raster = temp_glw_calculated + variable_raster
      }
      writeRaster(variable_raster, paste(results_path,k2, sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    #Generate rasters from the not ratios variables
    notratio_variables = c("AFKG","RFKG","RMKG","AMKG","MMKG","MFKG","MFSKG", "MMSKG","CKG","AFC","FR","GROWF","GROWM","MILK_YIELD_KG","LACT_PER", "MILK_FAT", "MILK_PROTEIN","MMSSOLID", "MMSCOMPOSTING", "MMSANAEROBIC", "MMSDAILY", "MMSUNCOVEREDLAGOON", "MMSLIQUID", "MMSBURNED", "MMSPASTURE","MMSDRYLOT")
    for(k1 in notratio_variables){
      variable_raster = cero_value_raster
      for (i in 1:nrow(dairy)){
        temp_code = dairy[i,"CODE"]
        temp_variable = dairy[i,k1]
        temp_zone_raster = calc(zone_rst,  function(x) {x== temp_code} )
        temp_zone_calculated_raster= temp_zone_raster * temp_variable
        variable_raster = temp_zone_calculated_raster + variable_raster
      }
      writeRaster(variable_raster, paste(results_path,k1, sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    #Generate rasters from feed variables
    feed_variables = c("AFLCIDE","OTLCIDE","AFLCIN","OTLCIN")

    for(k1 in feed_variables){
      variable_raster = cero_value_raster
      for (i in 1:nrow(dairy)){
        temp_code = dairy[i,"CODE"]
        temp_variable = dairy[i,k1]
        temp_zone_raster = calc(zone_rst,  function(x) {x== temp_code} )
        temp_zone_calculated_raster= temp_zone_raster * temp_variable
        variable_raster = temp_zone_calculated_raster + variable_raster
      }
      writeRaster(variable_raster, paste(feed_path,k1, sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    ########################################
    ## SYSTEM TRACK
    ########################################
    
    ## INITIALS
    ## AF = ADULT FEMALES (VACAS)
    ## AFN = ADULT FEMALES NO MILK (VACAS
    ## SECAS)
    ## AFM = ADULT FEMALES MILK (VACAS 
    ## EN PRODUCCION)
    ## AM = ADULT MALES (TOROS)
    ## YF = YOUNG FEMALES (VACONAS)
    ## YM = YOUNG MALES (TORETES)
    ## MF = MEAT FEMALES (HEMBRAS DE CARNE)
    ## MM = MEAT MALES (MACHOS DE CARNE)
    ## OT = OTHER ANIMALS (OTRAS CATEGORIAS
    ## DE ANIMALES FUERA DE LAS VACAS)
    kg_variables = c("AF","AM","RF","RM","MM","MF") 
    for(tipo in kg_variables){
      
      ##-------------------------------------
      ## ENERGY
      ##-------------------------------------
      
      ## 3.5.1.1 MAINTENANCE
      ## SEE PAGE 54 (GLEAM 2.0)
      
      # INPUT
      KG = raster(paste(path_name,"\\herd_track\\", tipo , "KG.tif", sep = ""))
      CfL = 0.386 ## pagina 54
      CfN = 0.322
      CfB = 0.370
      #CALCULATION
      if (tipo == "AF"){
        Cf = CfL
      }
      if (tipo == "AM" | tipo == "MM"){
        Cf = CfB
      }
      if (tipo == "RM"){
        Cf = CfB * 0.974
      }
      if (tipo == "MF"){
        Cf = CfN
      }
      if (tipo == "RF"){
        Cf = CfN * 0.974
      }
      tipo_result_raster = (KG ^ 0.75)*Cf
      #OUTPUT
      writeRaster(tipo_result_raster, paste(results_path2, tipo , "NEMAIN.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      
      ## 3.5.1.7 PREGNANCY
      ## SEE PAGE 57 (GLEAM 2.0)
      if (tipo == "AF" | tipo == "RF"){
        #INPUT
        outNEMAIN = raster(paste(results_path2, tipo , "NEMAIN.tif", sep = ""))
        Cp = 0.1
        FR = raster(paste(path_name , "\\herd_track\\FR.tif", sep = ""))
        AFC = raster(paste(path_name , "\\herd_track\\AFC.tif" , sep = ""))
        #CALCULATION
        if (tipo == "AF"){
          NEPREG = outNEMAIN * Cp * FR / 100.0
        }
        if (tipo == "RF"){
          AFC[AFC == 0] <- NA
          NEPREG = outNEMAIN * Cp* AFC /2 ###NEPREG = (outNEMAIN * Cp) / (AFC * 0.5)
        }
        #OUTPUT
        writeRaster(NEPREG, paste(results_path2, tipo , "NEPREG.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      }
      
      ## 3.5.1.3 GROWTH
      ## SEE PAGE 55 (GLEAM 2.0)
      if (tipo == "RF" | tipo == "RM" | tipo == "MF" | tipo == "MM"){
        #INPUT
        KG = raster(paste(path_name,"\\herd_track\\", tipo , "KG.tif", sep = ""))
        AFKG = raster(paste(path_name,"\\herd_track\\AFKG.tif", sep = "")) 
        AMKG = raster(paste(path_name,"\\herd_track\\AMKG.tif", sep = ""))
        GROWM = raster(paste(path_name,"\\herd_track\\GROWM.tif", sep = ""))
        GROWF = raster(paste(path_name,"\\herd_track\\GROWF.tif", sep = ""))
        CgF = 0.8
        CgM = 1.2
        CgC = 1.0 #for castrated animals
        #CALCULATION
        AFKG[AFKG == 0] <- NA
        AMKG[AMKG == 0] <- NA
        if (tipo == "RF"){
          NEGRO = 22.02 * ((KG / (CgF * AFKG)) ^ 0.75) * (GROWF ^ 1.097)
        }
        if (tipo == "MF"){
          NEGRO = 22.02 * ((KG / (CgF * AFKG)) ^ 0.75) * (GROWF ^ 1.097)
        }
        if (tipo == "RM"){
          NEGRO = 22.02 * ((KG / (CgM * AMKG)) ^ 0.75) * (GROWM ^ 1.097)
        }
        if (tipo == "MM"){
          NEGRO = 22.02 * ((KG / (CgC * AMKG)) ^ 0.75) * (GROWM ^ 1.097)
        }
        #OUTPUT
        writeRaster(NEGRO, paste(results_path2, tipo , "NEGRO.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      }
      
      ## 3.5.1.4 MILK PRODUCTION
      ## SEE PAGE 56 (GLEAM 2.0)
      if (tipo == "AF"){
        #INPUT
        MILK = raster(paste(path_name,"\\herd_track\\MILK_YIELD_KG.tif", sep = "")) #milk kg / day
        FAT = raster(paste(path_name,"\\herd_track\\MILK_FAT.tif", sep = ""))
        #CALCULATION
        NEMILK = MILK * (FAT * 0.40 + 1.47) 
        #OUTPUT
        writeRaster(NEMILK, paste(results_path2, tipo , "NEMILK.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      }
      
      ## 3.5.1.2 ACTIVITY (GRAZING) RANGE = 1; GRAZE = 2
      ## SEE PAGE 55 (GLEAM 2.0)
      
      # INPUT
      MMSpast = raster(paste(path_name,"\\herd_track\\MMSPASTURE.tif", sep = ""))
      # CALCULATIONS
      NEACT = tipo_result_raster * (MMSpast * 0.36 / 100.0)
      # OUTPUT
      writeRaster(NEACT, paste(results_path2, tipo , "NEACT.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      
      ## 3.5.1.10 TOTAL ENERGY
      ## SEE PAGE 58 (GLEAM 2.0)
      
      # INPUT GRID
      # CALCULATIONS
      outNEMAIN = raster(paste(results_path2, tipo , "NEMAIN.tif", sep = ""))
      outNEACT = raster(paste(results_path2, tipo , "NEACT.tif", sep = ""))
      # MAKES THE CALCULATIONS
      if (tipo == "AF"){
        outNEPREG = raster(paste(results_path2, tipo , "NEPREG.tif", sep = ""))
        AFNEMILK = raster(paste(results_path2, tipo, "NEMILK.tif", sep = ""))
        NETOT1 = outNEMAIN + outNEACT + outNEPREG + AFNEMILK
        NETOT2 = outNEMAIN + outNEACT + outNEPREG
        #OUTPUT GRID
        writeRaster(NETOT1, paste(results_path2, tipo , "MNETOT1.tif", sep = ""), format = "GTiff", overwrite=TRUE)
        writeRaster(NETOT2, paste(results_path2, tipo , "NNETOT1.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      }
      if (tipo == "RF"){
        outNEPREG = raster(paste(results_path2, tipo , "NEPREG.tif", sep = ""))
        NETOT1 = outNEMAIN + outNEACT + outNEPREG
        #OUTPUT GRID
        writeRaster(NETOT1, paste(results_path2, tipo , "NETOT1.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      } else{
        NETOT1 = outNEMAIN + outNEACT
        #OUTPUT GRID
        writeRaster(NETOT1, paste(results_path2, tipo , "NETOT1.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      }
    }
    
    ## 3.5.1.8 ENERGY RATIO FOR:
    ## MAINTENANCE (REM)
    ## GROWTH (REG)
    ## SEE PAGE 57 (GLEAM 2.0)
    for (group in c("AF","OT")){
      LCIDE = raster(paste(path_name,"\\feed_track\\", group, "LCIDE.tif", sep = ""))
      if (group == "AF"){
        n = 1
      }
      if (group == "OT"){
        n = 2
      }
      # MAKES THE CALCULATIONS
      LCIDE[LCIDE == 0] <- NA
      tmpREG = 1.164 - (0.00516 * LCIDE) + (0.00001308 * LCIDE * LCIDE) - (37.4 / LCIDE)
      tmpREM = 1.123 - (0.004092 * LCIDE) + (0.00001126 * LCIDE * LCIDE) - (25.4 / LCIDE)
      REG = tmpREG
      REG[REG < 0] <- NA
      REM = tmpREM
      REM[REM < 0] <- NA
      #OUTPUT
      writeRaster(tmpREG, paste(results_ge_feedintake,"REGTMP", n , ".tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(tmpREM, paste(results_ge_feedintake,"REMTMP", n , ".tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(REG, paste(results_ge_feedintake,"REG", n , ".tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(REM, paste(results_ge_feedintake,"REM", n , ".tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    #INPUT
    AFMNEtot1 =  raster(paste(results_path2,"AFMNETOT1.tif", sep = ""))
    AFNNEtot1 =  raster(paste(results_path2,"AFNNETOT1.tif", sep = ""))
    RFNEtot1 =  raster(paste(results_path2,"RFNETOT1.tif", sep = ""))
    MFNEtot1 =  raster(paste(results_path2,"MFNETOT1.tif", sep = ""))
    AMNEtot1 =  raster(paste(results_path2,"AMNETOT1.tif", sep = ""))
    RMNEtot1 =  raster(paste(results_path2,"RMNETOT1.tif", sep = ""))
    MMNEtot1 =  raster(paste(results_path2,"MMNETOT1.tif", sep = ""))
    MFNEtot1 =  raster(paste(results_path2,"MFNETOT1.tif", sep = ""))
    RFNEpreg =  raster(paste(results_path2,"RFNEPREG.tif", sep = ""))
    RFNEgro =  raster(paste(results_path2,"RFNEGRO.tif", sep = ""))
    RMNEgro =  raster(paste(results_path2,"RMNEGRO.tif", sep = ""))
    MMNEgro =  raster(paste(results_path2,"MMNEGRO.tif", sep = ""))
    MFNEgro =  raster(paste(results_path2,"MFNEGRO.tif", sep = ""))
    REM1 = raster(paste(results_ge_feedintake,"REM1.tif", sep = ""))
    REM2 = raster(paste(results_ge_feedintake,"REM2.tif", sep = ""))
    REG1 = raster(paste(results_ge_feedintake,"REG1.tif", sep = ""))
    REG2 = raster(paste(results_ge_feedintake,"REG2.tif", sep = ""))
    LCIDE1 = raster(paste(path_name,"\\feed_track\\AFLCIDE.tif", sep = ""))
    LCIDE2 = raster(paste(path_name,"\\feed_track\\OTLCIDE.tif", sep = ""))
    
    ## 3.5.1.10 TOTAL ENERGY
    ## SEE PAGE 58 (GLEAM 2.0)
    
    # CALCULATIONS
    REM1[REM1 == 0] <- NA
    LCIDE1[LCIDE1 == 0] <- NA
    REM2[REM2 == 0] <- NA
    LCIDE2[LCIDE2 == 0] <- NA
    AFMGE = (AFMNEtot1 / REM1) / (LCIDE1 / 100.0)
    AFNGE = (AFNNEtot1 / REM1) / (LCIDE1 / 100.0)
    RFGE = ((RFNEtot1 / REM2) + (RFNEgro / REG2)) / (LCIDE2 / 100.0)
    AMGE = (AMNEtot1 / REM2) / (LCIDE2 / 100.0)
    RMGE = ((RMNEtot1 / REM2) + (RMNEgro / REG2)) / (LCIDE2 / 100.0)
    MMGE = ((MMNEtot1 / REM2) + (MMNEgro / REG2)) / (LCIDE2 / 100.0)
    MFGE = ((MFNEtot1 / REM2) + (MFNEgro / REG2)) / (LCIDE2 / 100.0)
    # OUTPUT
    writeRaster(AFMGE, paste(results_ge_feedintake,"AFMGE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    writeRaster(AFNGE, paste(results_ge_feedintake,"AFNGE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    writeRaster(RFGE, paste(results_ge_feedintake,"RFGE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    writeRaster(AMGE, paste(results_ge_feedintake,"AMGE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    writeRaster(RMGE, paste(results_ge_feedintake,"RMGE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    writeRaster(MMGE, paste(results_ge_feedintake,"MMGE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    writeRaster(MMGE, paste(results_ge_feedintake,"MFGE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    #AFGEout = species + "\\system_track\\GE_feedintake\\AFGE"
    #MFGEout = species + "\\system_track\\GE_feedintake\\MFGE"
    for (tipo in c("AFM","AFN", "RF", "AM", "RM", "MM","MF")){
      #INPUT
      LCIGE = 18.45
      GE = raster(paste(results_ge_feedintake, tipo, "GE.tif" , sep = ""))
      # CALCULATIONS
      INTAKE = GE / LCIGE
      # OUTPUT
      writeRaster(INTAKE, paste(results_ge_feedintake, tipo , "INTAKE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    milk = raster(paste(path_name,"\\herd_track\\MILK_YIELD_KG.tif", sep = ""))
    protein = raster(paste(path_name,"\\herd_track\\MILK_PROTEIN.tif", sep = ""))
    fat = raster(paste(path_name,"\\herd_track\\MILK_FAT.tif", sep = ""))
    af = raster(paste(path_name,"\\herd_track\\AF.tif", sep = ""))
    lact_per = raster(paste(path_name,"\\herd_track\\LACT_PER.tif", sep = ""))
    
    ##-------------------------------------
    ## METHANE CH4 EMISSIONS
    ##-------------------------------------
    ## NUM = ANIMALS NUMBER
    ## 34 CONVERSION FACTOR CH4 TO CO2EQ
    ## SEE PAGE 100 (GLEAM 2.0)
    
    ## 4.2 FROM ENTERIC FERMENTATION
    ## SEE PAGE 67 (GLEAM 2.0)
    for (group in c("AF","OT")){
      LCIDE = raster(paste(path_name,"\\feed_track\\", group, "LCIDE.tif", sep = ""))
      if (group == "AF"){
        n = 1
      }
      if (group == "OT"){
        n = 2
      }
      #CALCULATION
      Ym = 9.75 - (LCIDE * 0.05)
      #OUTPUT
      writeRaster(Ym, paste(results_methame_emss, "YM", n, ".tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    for (tipo in c("AFN","AFM","AM","RF","RM","MM", "MF")){
      # INPUT
      GE = raster(paste(results_ge_feedintake, tipo, "GE.tif", sep = ""))
      # CALCULATIONS
      if (tipo == "AFM" | tipo == "AFN"){
        anim_num = raster(paste(path_name,"\\herd_track\\AF.tif", sep = ""))
        Ym = raster(paste(results_methame_emss,"YM1.tif", sep = ""))
        CH41 = (GE * Ym / 100) / 55.65
      } 
      else {
        anim_num = raster(paste(path_name,"\\herd_track\\", tipo, ".tif", sep = ""))
        Ym = raster(paste(results_methame_emss,"YM2.tif", sep = ""))
        CH41 = (GE * Ym / 100) / 55.65
      }
      # OUTPUT
      writeRaster(CH41, paste(results_methame_emss, tipo, "CH41.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      
      # 5.2 MANURE STORAGE
      #INPUT
      if (tipo == "AFM" | tipo == "AFN"){
        LCIDE = raster(paste(path_name,"\\feed_track\\AFLCIDE.tif", sep = ""))
      }
      else {
        LCIDE = raster(paste(path_name,"\\feed_track\\OTLCIDE.tif", sep = ""))
      }
      LCIGE = 18.45
      GE = raster(paste(results_ge_feedintake, tipo, "GE.tif", sep = ""))
      # CALCULATIONS
      VS = GE * (1.04 - (LCIDE / 100)) * (0.92 / LCIGE)
      # OUTPUT
      writeRaster(VS, paste(results_methame_emss, tipo, "VS.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    
      # INPUT
      temp = raster(paste("input\\","temp.tif", sep = ""))
      temp_resample = resample(temp, one_value_raster)
      temp_cutoff = raster(paste("input\\", "temp_cutoff.tif", sep = ""))
      temp_cutoff_resample = resample(temp_cutoff, one_value_raster)*one_value_raster
      # CALCULATIONS
      reclass_MCFsolid <- matrix(c(-100, 14, 2, 14, 26, 4, 26, 1000, 5),ncol = 3,byrow = TRUE)
      MCFsolid <- (reclassify(temp_resample, reclass_MCFsolid))*one_value_raster
      reclass_MCFcomposting <- matrix(c(-100, 14, 0.5, 14, 26, 1, 26, 1000, 1.5),ncol = 3,byrow = TRUE)
      MCFcomposting <- (reclassify(temp_resample, reclass_MCFcomposting))*one_value_raster
      MCFanaerobic = 10.0 * one_value_raster
      reclass_MCFdaily <- matrix(c(-100, 14, 0.1, 14, 26, 0.5, 26, 1000, 1),ncol = 3,byrow = TRUE)
      MCFdaily <- (reclassify(temp_resample, reclass_MCFdaily))*one_value_raster
      MCFuncoveredlagoon = 44.953 + 2.6993 * temp_cutoff_resample - 0.0527 * temp_cutoff_resample * temp_cutoff_resample
      MCFuncoveredlagoon[MCFuncoveredlagoon < 0] <- NA
      MCFliquid = 19.494 - 1.5573 * temp_cutoff_resample + 0.1351 * temp_cutoff_resample * temp_cutoff_resample
      MCFliquid[MCFliquid < 0] <- NA
      MCFburned = 10.0 * one_value_raster
      reclass_MCFpasture <- matrix(c(-100, 14, 1, 14, 26, 1.5, 26, 1000, 2),ncol = 3,byrow = TRUE)
      MCFpasture <- (reclassify(temp_resample, reclass_MCFpasture))*one_value_raster
      reclass_MCFdrylot <- matrix(c(-100, 14, 1, 14, 26, 1.5, 26, 1000, 2),ncol = 3,byrow = TRUE)
      MCFdrylot <- (reclassify(temp_resample, reclass_MCFdrylot))*one_value_raster
      
      # OUTPUT
      writeRaster(MCFsolid, paste(results_mcf, "MCFSOLID.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(MCFcomposting, paste(results_mcf, "MCFCOMPOSTING.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(MCFanaerobic, paste(results_mcf, "MCFANAEROBIC.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(MCFdaily, paste(results_mcf, "MCFDAILY.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(MCFuncoveredlagoon, paste(results_mcf, "MCFUNCOVEREDLAGOON.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(MCFliquid, paste(results_mcf, "MCFLIQUID.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(MCFburned, paste(results_mcf, "MCFBURNED.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(MCFpasture, paste(results_mcf, "MCFPASTURE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(MCFdrylot, paste(results_mcf, "MCFDRYLOT.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      
      # CREATES THE MCFMANURE RASTER
      # INPUT
      MMSanaerobic = raster(paste(path_name,"\\herd_track\\MMSANAEROBIC.tif", sep = ""))
      MMSburned = raster(paste(path_name,"\\herd_track\\MMSBURNED.tif", sep = ""))
      MMScomposting = raster(paste(path_name,"\\herd_track\\MMSCOMPOSTING.tif", sep = ""))
      MMSdaily = raster(paste(path_name,"\\herd_track\\MMSDAILY.tif", sep = ""))
      MMSliquid = raster(paste(path_name,"\\herd_track\\MMSLIQUID.tif", sep = ""))
      MMSpasture = raster(paste(path_name,"\\herd_track\\MMSPASTURE.tif", sep = ""))
      MMSsolid = raster(paste(path_name,"\\herd_track\\MMSSOLID.tif", sep = ""))
      MMSuncoveredlagoon = raster(paste(path_name,"\\herd_track\\MMSUNCOVEREDLAGOON.tif", sep = ""))
      MMSdrylot = raster(paste(path_name,"\\herd_track\\MMSDRYLOT.tif", sep = ""))
      
      # CALCULATIONS
      MCFmanure = MMSanaerobic * MCFanaerobic + MMSburned * MCFburned + MMScomposting * MCFcomposting + MMSdaily * MCFdaily + 
        MMSliquid * MCFliquid + MMSpasture * MCFpasture + MMSsolid * MCFsolid + MMSuncoveredlagoon * MCFuncoveredlagoon + MMSdrylot * MCFdrylot
      # OUTPUT
      writeRaster(MCFmanure, paste(results_mcf, "MCFMANURE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    for (var in c("AFM","AFN","RF","AM","RM","MM","MF")){ 
      # INPUT
      CH41 = raster(paste(results_methame_emss, var, "CH41.tif", sep = ""))
      # CALCULATIONS
      if (var == "AFM"){
        anim_num = raster(paste(path_name, "\\herd_track\\AF.tif", sep = ""))
        totCH41 = lact_per * CH41 * anim_num * 34
      }
      else if (var == "AFN"){
        anim_num = raster(paste(path_name, "\\herd_track\\AF.tif", sep = ""))
        totCH41 = (365.0 - lact_per) * CH41 * anim_num * 34
      }
      else {
        anim_num = raster(paste(path_name, "\\herd_track\\", var, ".tif", sep = ""))
        totCH41 = 365.0 * CH41 * anim_num * 34
      }
      # OUTPUT
      writeRaster(totCH41, paste(results_methame_emss, "CH41CO2TOT", var, ".tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    for (var in c("AFM","AFN","RF","AM","RM","MM","MF")){
      # INPUT
      VS = raster(paste(results_methame_emss, var, "VS.tif", sep = ""))
      MCFmanure = raster(paste(results_mcf, "MCFMANURE.tif", sep = ""))
      # CALCULATIONS
      CH42 = 0.67 * 0.0001 * 0.13 * MCFmanure * VS ##??
      # OUTPUT
      writeRaster(CH42, paste(results_methame_emss, var, "CH42.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    for (var in c("AFM","AFN","RF","AM","RM","MM","MF")){
      # INPUT
      CH42 = raster(paste(results_methame_emss, var, "CH42.tif", sep = ""))
      if (var == "AFM"){
        anim_num = raster(paste(path_name, "\\herd_track\\AF.tif", sep = ""))
        totCH42 = lact_per * CH42 * anim_num * 34
      }
      else if (var == "AFN"){
        anim_num = raster(paste(path_name, "\\herd_track\\AF.tif", sep = ""))
        totCH42 = (365.0 - lact_per) * CH42 * anim_num * 34
      }
      else{
        anim_num = anim_num = raster(paste(path_name, "\\herd_track\\", var, ".tif", sep = ""))
        totCH42 = 365.0 * CH42 * anim_num * 34
      } 
      # OUTPUT
      writeRaster(totCH42, paste(results_methame_emss, "CH42CO2TOT", var, ".tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    ##-------------------------------------
    ## NITROUS OXIDE N20 EMISSIONS
    ##-------------------------------------
    ## NUM = ANIMALS NUMBER
    ## 298 CONVERSION FACTOR N2O TO CO2EQ
    ## SEE PAGE 100 (GLEAM 2.0)
    
    ## 4.4 FROM MANURE MANAGMENT
    ## SEE PAGE 69 (GLEAM 2.0)
    
    ## 4.4.1 NITROGEN EXCRETION RATE
    ## SEE PAGE 69 (GLEAM 2.0)
    
    ## STEP 1 INTAKE CALCULATION
    for (var in c("AFM","AFN","RF","AM","RM","MM","MF")){
      # INPUT
      inTAKE = raster(paste(results_ge_feedintake, var, "INTAKE.tif", sep = ""))
      if (var == "AFM" | var == "AFN"){
        LCIN = raster(paste(path_name,"\\feed_track\\AFLCIN.tif", sep = ""))
      }
      else {
        LCIN = raster(paste(path_name,"\\feed_track\\OTLCIN.tif", sep = ""))
      }
      # CALCULATION
      NINTAKE = (LCIN / 1000) * inTAKE
      # OUTPUT
      writeRaster(NINTAKE, paste(results_excretion, var, "NINTAKE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    # STEP 2 RETENTION CALCULATION
    # INPUT
    AF = raster(paste(path_name,"\\herd_track\\AF.tif", sep = ""))
    Ckg = raster(paste(path_name,"\\herd_track\\CKG.tif", sep = ""))
    GrowM = raster(paste(path_name,"\\herd_track\\GROWM.tif", sep = ""))
    GrowM[GrowM == 0] <- NA
    GrowF = raster(paste(path_name,"\\herd_track\\GROWF.tif", sep = ""))
    GrowF[GrowF == 0] <- NA
    AFC = raster(paste(path_name,"\\herd_track\\AFC.tif", sep = ""))
    AFC[AFC == 0] <- NA
    milk = raster(paste(path_name,"\\herd_track\\MILK_YIELD_KG.tif", sep = ""))
    MilkP = (raster(paste(path_name,"\\herd_track\\MILK_PROTEIN.tif", sep = "")))/100
    RFNEgro = raster(paste(results_path2,"RFNEGRO.tif", sep = ""))
    RMNEgro = raster(paste(results_path2,"RMNEGRO.tif", sep = ""))
    MMNEgro = raster(paste(results_path2,"MMNEGRO.tif", sep = ""))
    MFNEgro = raster(paste(results_path2,"MFNEGRO.tif", sep = ""))
    # CALCULATION
    for (var in c("AFM","AFN","RF","AM","RM","MM","MF")){
      if (var == "AFM"){
        NRETENTION = (milk * MilkP/6.38)+(Ckg/365 * (268-(7.03 * RFNEgro/GrowF))*0.001/6.25)
      }
      else if (var == "AM" | var == "AFN"){
        NRETENTION = one_value_raster * 0
      }
      else if (var == "RF"){
        NRETENTION = (GrowF * (268 - (7.03 * RFNEgro/GrowF)) * 0.001/6.25) + (Ckg/365 * (268-(7.03 * RFNEgro/GrowF))*0.001/6.25) / AFC
      }
      else {
        NRETENTION = (GrowM * (268 - (7.03 * RMNEgro/GrowM)) * 0.001/6.25)
      } 
      # OUTPUT
      writeRaster( NRETENTION, paste(results_excretion, var, "NRETENTION.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    # STEP 3 N EXCRETION
    for (var in c("AFM","AFN","RF","AM","RM","MM","MF")){
      # INPUT
      Nintake = raster(paste(results_excretion, var, "NINTAKE.tif", sep = "")) 
      Nretention = raster(paste(results_excretion, var, "NRETENTION.tif", sep = ""))
      # CALCULATIONS
      if (var == "AFN"){
        Nx = (365.0 - lact_per) * (Nintake - Nretention)
        Nx[Nx < 0] <- 0
      }
      else if (var == "AFM"){
        Nx = (lact_per) * (Nintake - Nretention)
        Nx[Nx < 0] <- 0
      }
      else{
        Nx = 365.0 * (Nintake - Nretention)
      }
      # OUTPUT
      writeRaster( Nx, paste(results_excretion, var, "NX.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      
      ## 4.4.2 N2O DIRECT EMISSIONS FROM 
      ## MANURE MANAGMENT
      ## SEE PAGE 70 (GLEAM 2.0)
      
      # INPUT
      N2Olagoon = 0
      N2Oliquid = 0.005
      N2Osolid = 0.005
      N2Odrylot = 0.02
      N2Opasture = 0
      N2Odaily = 0
      N2Oburned = 0.02
      N2Oanaerobic = 0
      N2Ocomposting = 0.1
      MMSdrylot = raster(paste(path_name,"\\herd_track\\MMSDRYLOT.tif", sep = ""))
      MMSanaerobic = raster(paste(path_name,"\\herd_track\\MMSANAEROBIC.tif", sep = ""))
      MMSburned = raster(paste(path_name,"\\herd_track\\MMSBURNED.tif", sep = ""))
      MMScomposting = raster(paste(path_name,"\\herd_track\\MMSCOMPOSTING.tif", sep = ""))
      MMSdaily = raster(paste(path_name,"\\herd_track\\MMSDAILY.tif", sep = ""))
      MMSliquid = raster(paste(path_name,"\\herd_track\\MMSLIQUID.tif", sep = ""))
      MMSpasture = raster(paste(path_name,"\\herd_track\\MMSPASTURE.tif", sep = ""))
      MMSsolid = raster(paste(path_name,"\\herd_track\\MMSSOLID.tif", sep = ""))
      MMSuncoveredlagoon = raster(paste(path_name,"\\herd_track\\MMSUNCOVEREDLAGOON.tif", sep = ""))
      
      if (var == "AFM" | var == "AFN"){
        LCIDE = raster(paste(path_name,"\\feed_track\\AFLCIDE.tif", sep = ""))
      }
      else {
        LCIDE = raster(paste(path_name,"\\feed_track\\OTLCIDE.tif", sep = ""))
      }
      # CALCULATIONS
      N2OCFmanure = MMSanaerobic * N2Oanaerobic + MMSburned * N2Oburned * (100.0 - LCIDE) / 100 + MMScomposting * N2Ocomposting + 
        MMSdaily *  N2Odaily + MMSliquid * N2Oliquid + MMSpasture * N2Opasture + MMSsolid * N2Osolid + MMSuncoveredlagoon * N2Olagoon  + MMSdrylot * N2Odrylot
      # OUTPUT
      writeRaster( N2OCFmanure, paste(results_direct_N2O, "N2OCFMAN", var, ".tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    for (var in c("AFM","AFN","RF","AM","RM","MM","MF")){
      # INPUT
      Nx = raster(paste(results_excretion, var, "NX.tif", sep = ""))
      N2OCFmanure = raster(paste(results_direct_N2O, "N2OCFMAN", var, ".tif", sep = ""))
      # CALCULATIONS
      NOdir = N2OCFmanure * Nx * 44 / 2800 
      # OUTPUT
      writeRaster(NOdir, paste(results_direct_N2O, var, "NODIR.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    ## 4.4.4 INDIRECT N2O EMISSIONS FROM
    ## VOLATILIZATION
    ## SEE PAGE 71 (GLEAM 2.0)
    
    # INPUT
    VOLliquid = 40
    VOLsolid = 30
    VOLpasture = 0
    VOLdaily = 7
    VOLlagoon = 35
    VOLanaerobic = 0
    VOLcomposting = 40
    VOLdrylot = 20
    MMSanaerobic = raster(paste(path_name,"\\herd_track\\MMSANAEROBIC.tif", sep = ""))
    MMScomposting = raster(paste(path_name,"\\herd_track\\MMSCOMPOSTING.tif", sep = ""))
    MMSdaily = raster(paste(path_name,"\\herd_track\\MMSDAILY.tif", sep = ""))
    MMSliquid = raster(paste(path_name,"\\herd_track\\MMSLIQUID.tif", sep = ""))
    MMSpasture = raster(paste(path_name,"\\herd_track\\MMSPASTURE.tif", sep = ""))
    MMSsolid = raster(paste(path_name,"\\herd_track\\MMSSOLID.tif", sep = ""))
    MMSuncoveredlagoon = raster(paste(path_name,"\\herd_track\\MMSUNCOVEREDLAGOON.tif", sep = ""))
    MMSdrylot = raster(paste(path_name,"\\herd_track\\MMSDRYLOT.tif", sep = ""))
    # CALCULATIONS
    CFVOLmanure = MMSliquid * VOLliquid + MMSsolid * VOLsolid + MMSpasture * VOLpasture + MMSdaily * VOLdaily + MMSuncoveredlagoon * VOLlagoon + 
      MMSanaerobic * VOLanaerobic + MMScomposting * VOLcomposting + MMSdrylot * VOLdrylot
    # OUTPUT
    writeRaster(CFVOLmanure, paste(results_indirect_N2O, "CFVOLMANURE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    
    for (var in c("AFM","AFN","RF","AM","RM","MM","MF")){
      # INPUT
      outCFVOLmanure = raster(paste(results_indirect_N2O, "CFVOLMANURE.tif", sep = ""))
      Nx = raster(paste(results_excretion, var, "NX.tif", sep = ""))
      # CALCULATIONS            
      Mvol = outCFVOLmanure / 10000 * Nx
      NOvol = Mvol * 0.01 * 44 / 28
      # OUTPUT
      writeRaster(Mvol, paste(results_indirect_N2O, var, "MVOL.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(NOvol, paste(results_indirect_N2O, var, "NOVOL.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    ## 4.4.4 INDIRECT N2O EMISSION FROM 
    ## LEACHING
    ## SEE PAGE 71 (GLEAM 2.0)
    
    # INPUT
    LEACHliquid_total = raster(paste("input\\", "leachliquid.tif", sep = ""))
    LEACHliquid = resample(LEACHliquid_total, one_value_raster)
    LEACHsolid_total = raster(paste("input\\", "leachsolid.tif", sep = ""))
    LEACHsolid = resample(LEACHsolid_total, one_value_raster)
    # CALCULATIONS
    CFleachmanure = MMSliquid * LEACHliquid + MMSsolid * LEACHsolid
    # OUTPUT
    writeRaster(CFleachmanure, paste(results_indirect_N2O, "CFLEACHMANURE.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    
    for (var in c("AFM","AFN","RF","AM","RM","MM","MF")){
      # INPUT
      outCFleachmanure = raster(paste(results_indirect_N2O, "CFLEACHMANURE.tif", sep = ""))
      Nx = raster(paste(results_excretion, var, "NX.tif", sep = ""))
      # CALCULATIONS
      Mleach = outCFleachmanure / 10000 * Nx
      NOleach = Mleach * 0.0075 * 44 / 28
      # OUTPUT
      writeRaster(Mleach, paste(results_indirect_N2O, var, "MLEACH.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      writeRaster(NOleach, paste(results_indirect_N2O, var, "NOLEACH.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    ## 4.5 TOTAL N2O EMISSIONS PER ANIMAL
    ## SEE PAGE 73 (GLEAM 2.0)
    
    for (var in c("AFM","AFN","RF","AM","RM","MM","MF")){
      # INPUT
      NOdir = raster(paste(results_direct_N2O, var, "NODIR.tif", sep = ""))
      NOvol = raster(paste(results_indirect_N2O, var, "NOVOL.tif", sep = ""))
      NOleach = raster(paste(results_indirect_N2O, var, "NOLEACH.tif", sep = ""))
      # CALCULATIONS            
      NOtot = NOdir + NOvol + NOleach
      # OUTPUT
      writeRaster(NOtot, paste(results_n2o, var, "NOTOT.tif", sep = ""), format = "GTiff", overwrite=TRUE)
      
      #6.6 TOTALIZING EMISSION TO HERD LEVEL
      # INPUT
      if (var == "AFM" | var == "AFN"){
        num = raster(paste(path_name, "\\herd_track\\AF.tif", sep = ""))
      }
      else{
        num = raster(paste(path_name, "\\herd_track\\", var, ".tif", sep = ""))
      }
      # CALCULATIONS
      NOtotal = num * NOtot * 298
      # OUTPUT
      writeRaster(NOtotal, paste(results_n2o, "NOTOTCO2", var, ".tif", sep = ""), format = "GTiff", overwrite=TRUE)
    }
    
    ## 6.2.1 N2O EMISSIONS FROM MANURE DEPOSITED ON PASTURES
    ## SEE PAGE 82 (GLEAM 2.0)
    
    ## 90% pasture dry matter GLEAM2.0
    ## N retention and excretion per animal type
    AFNNx = raster(paste(results_excretion,"AFNNX.tif", sep = ""))
    AF = raster(paste(path_name,"\\herd_track\\AF.tif", sep = ""))
    AFN_NXTOTAL = AF*AFNNx
    AFN_MANURE = AFN_NXTOTAL*MMSpasture/100
    AFN_N2OFEEDMAN =  AFN_MANURE*(0.02+0.2*0.01+0.3*0.0075)*44/28*298
    
    AFMNx = raster(paste(results_excretion,"AFMNX.tif", sep = ""))
    AFM_NXTOTAL = AF*AFMNx
    AFM_MANURE = AFM_NXTOTAL*MMSpasture/100
    AFM_N2OFEEDMAN =  AFM_MANURE*(0.02+0.2*0.01+0.3*0.0075)*44/28*298
    
    RFNx = raster(paste(results_excretion,"RFNX.tif", sep = ""))
    RF = raster(paste(path_name,"\\herd_track\\RF.tif", sep = ""))
    RF_NXTOTAL = RF*RFNx
    RF_MANURE = RF_NXTOTAL*MMSpasture/100
    RF_N2OFEEDMAN =  RF_MANURE*(0.02+0.2*0.01+0.3*0.0075)*44/28*298
    
    AMNx = raster(paste(results_excretion,"AMNX.tif", sep = ""))
    AM = raster(paste(path_name,"\\herd_track\\AM.tif", sep = ""))
    AM_NXTOTAL = AM*AMNx
    AM_MANURE = AM_NXTOTAL*MMSpasture/100
    AM_N2OFEEDMAN =  AM_MANURE*(0.02+0.2*0.01+0.3*0.0075)*44/28*298
    
    RMNx = raster(paste(results_excretion,"RMNX.tif", sep = ""))
    RM = raster(paste(path_name,"\\herd_track\\RM.tif", sep = ""))
    RM_NXTOTAL = RM*RMNx
    RM_MANURE = RM_NXTOTAL*MMSpasture/100
    RM_N2OFEEDMAN =  RM_MANURE*(0.02+0.2*0.01+0.3*0.0075)*44/28*298
    
    MMNx = raster(paste(results_excretion,"MMNX.tif", sep = ""))
    MM = raster(paste(path_name,"\\herd_track\\MM.tif", sep = ""))
    MM_NXTOTAL = MM*MMNx
    MM_MANURE = MM_NXTOTAL*MMSpasture/100
    MM_N2OFEEDMAN =  MM_MANURE*(0.02+0.2*0.01+0.3*0.0075)*44/28*298
    
    MFNx = raster(paste(results_excretion,"MFNX.tif", sep = ""))
    MF = raster(paste(path_name,"\\herd_track\\MF.tif", sep = ""))
    MF_NXTOTAL = MF*MFNx
    MF_MANURE = MF_NXTOTAL*MMSpasture/100
    MF_N2OFEEDMAN =  MF_MANURE*(0.02+0.2*0.01+0.3*0.0075)*44/28*298
    
    ########################################
    ## RESULTS GENERATION
    ########################################
    
    #construct the data table of parameters
    parameters= dairy
    base_table = ""
    parameters_base = c("REGION", "ESTRATO", "PRODUCTO", "CODE",
                        "AFEXIT","AMEXIT","MFEXIT","MMEXIT","RFEXIT",
                        "Milk_production", "Meat_production_FF", "Meat_production_FM", "Meat_production_M")
    for(i in parameters_base){
      base_table = data.frame(base_table,parameters[,i])
    }
    colnames(base_table)=c("",parameters_base)
    
    herd = base_table
    emissions = base_table
    
    #construct the results table data
    herd <- transform(herd, Meat_total = Meat_production_FF + Meat_production_FM + Meat_production_M)
    herd_variables = c("AF","AM","RF","RM","MM","MF")
    for(i in herd_variables){
      inValueRaster = raster(paste(data_path_herdtrack,i, ".tif", sep = ""))
      temp_herd = zonal(inValueRaster, zone_rst, 'sum')
      colnames(temp_herd)=c("CODE", i)
      herd=merge(herd, temp_herd, by = "CODE", all = TRUE)
      
    } 
    herd <- mutate(herd, AF = ifelse(AF < 0 | is.na(AF), 0, AF))
    herd <- mutate(herd, AM = ifelse(AM < 0 | is.na(AM), 0, AM))
    herd <- mutate(herd, RF = ifelse(RF < 0 | is.na(RF), 0, RF))
    herd <- mutate(herd, RM = ifelse(RM < 0 | is.na(RM), 0, RM))
    herd <- mutate(herd, MM = ifelse(MM < 0 | is.na(MM), 0, MM))
    herd <- mutate(herd, MF = ifelse(MF < 0 | is.na(MF), 0, MF))
    herd <- transform(herd, TOTAL_HERD = AF + AM + RF + RM + MM + MF)
    
    write.csv(herd, file = paste(table_path, "herd.csv",sep = ""))
    
    #construct the results table data
    emissions_variables = c("CH41CO2TOT","CH42CO2TOT","NOTOTCO2","NOTOTPASTURE")
    emissions_variables1 = c("AFM","AFN","AM","RF","RM","MM","MF")
    
    emissions <- transform(emissions, Meat_total = Meat_production_FF + Meat_production_FM + Meat_production_M)
    for(n in emissions_variables){
      for(x in emissions_variables1){
        if(n == "CH41CO2TOT" | n == "CH42CO2TOT"){
          inValueRaster = raster(paste(data_path_systemtrack,"Methane_emss\\",n,x, ".tif", sep = ""))
        }
        else if( n == "NOTOTCO2"){
          inValueRaster = raster(paste(data_path_systemtrack,"N2O_emss\\",n,x, ".tif", sep = ""))
        }
        else if(n=="NOTOTPASTURE"){
          if(x=="AFM"){
            inValueRaster = AFM_N2OFEEDMAN
          }
          else if(x=="AFN"){
            inValueRaster = AFN_N2OFEEDMAN
          }
          else if(x=="AM"){
            inValueRaster = AM_N2OFEEDMAN
          }
          else if(x=="RF"){
            inValueRaster = RF_N2OFEEDMAN
          }
          else if(x=="RM"){
            inValueRaster = RM_N2OFEEDMAN
          }
          else if(x=="MM"){
            inValueRaster = MM_N2OFEEDMAN
          }
          else if(x=="MF"){
            inValueRaster = MF_N2OFEEDMAN
          }
        }
        temp_emissions = zonal(inValueRaster, zone_rst, 'sum')
        colnames(temp_emissions)=c("CODE", paste(n,x, sep = ""))
        emissions=merge(emissions, temp_emissions, by = "CODE", all = TRUE)
      }
    } 
    emissions <- mutate(emissions, CH41CO2TOTAFM = ifelse(CH41CO2TOTAFM < 0 | is.na(CH41CO2TOTAFM), 0, CH41CO2TOTAFM))
    emissions <- mutate(emissions, CH41CO2TOTAFN = ifelse(CH41CO2TOTAFN < 0 | is.na(CH41CO2TOTAFN), 0, CH41CO2TOTAFN))
    emissions <- mutate(emissions, CH41CO2TOTAM = ifelse(CH41CO2TOTAM < 0 | is.na(CH41CO2TOTAM), 0, CH41CO2TOTAM))
    emissions <- mutate(emissions, CH41CO2TOTRF = ifelse(CH41CO2TOTRF < 0 | is.na(CH41CO2TOTRF), 0, CH41CO2TOTRF))
    emissions <- mutate(emissions, CH41CO2TOTRM = ifelse(CH41CO2TOTRM < 0 | is.na(CH41CO2TOTRM), 0, CH41CO2TOTRM))
    emissions <- mutate(emissions, CH41CO2TOTMM = ifelse(CH41CO2TOTMM < 0 | is.na(CH41CO2TOTMM), 0, CH41CO2TOTMM))
    emissions <- mutate(emissions, CH41CO2TOTMF = ifelse(CH41CO2TOTMF < 0 | is.na(CH41CO2TOTMF), 0, CH41CO2TOTMF))
    emissions <- transform(emissions, CH4_from_enteric_fermentation = CH41CO2TOTAFM + CH41CO2TOTAFN + CH41CO2TOTAM + CH41CO2TOTRF + CH41CO2TOTRM + CH41CO2TOTMM + CH41CO2TOTMF)
    emissions <- mutate(emissions, CH42CO2TOTAFM = ifelse(CH42CO2TOTAFM < 0 | is.na(CH42CO2TOTAFM), 0, CH42CO2TOTAFM))
    emissions <- mutate(emissions, CH42CO2TOTAFN = ifelse(CH42CO2TOTAFN < 0 | is.na(CH42CO2TOTAFN), 0, CH42CO2TOTAFN))
    emissions <- mutate(emissions, CH42CO2TOTAM = ifelse(CH42CO2TOTAM < 0 | is.na(CH42CO2TOTAM), 0, CH42CO2TOTAM))
    emissions <- mutate(emissions, CH42CO2TOTRF = ifelse(CH42CO2TOTRF < 0 | is.na(CH42CO2TOTRF), 0, CH42CO2TOTRF))
    emissions <- mutate(emissions, CH42CO2TOTRM = ifelse(CH42CO2TOTRM < 0 | is.na(CH42CO2TOTRM), 0, CH42CO2TOTRM))
    emissions <- mutate(emissions, CH42CO2TOTMM = ifelse(CH42CO2TOTMM < 0 | is.na(CH42CO2TOTMM), 0, CH42CO2TOTMM))
    emissions <- mutate(emissions, CH42CO2TOTMF = ifelse(CH42CO2TOTMF < 0 | is.na(CH42CO2TOTMF), 0, CH42CO2TOTMF))
    emissions <- transform(emissions, CH4_from_manure_management = CH42CO2TOTAFM + CH42CO2TOTAFN + CH42CO2TOTAM + CH42CO2TOTRF + CH42CO2TOTRM + CH42CO2TOTMM + CH42CO2TOTMF )
    emissions <- mutate(emissions, NOTOTCO2AFM = ifelse(NOTOTCO2AFM < 0 | is.na(NOTOTCO2AFM), 0, NOTOTCO2AFM))
    emissions <- mutate(emissions, NOTOTCO2AFN = ifelse(NOTOTCO2AFN < 0 | is.na(NOTOTCO2AFN), 0, NOTOTCO2AFN))
    emissions <- mutate(emissions, NOTOTCO2AM = ifelse(NOTOTCO2AM < 0 | is.na(NOTOTCO2AM), 0, NOTOTCO2AM))
    emissions <- mutate(emissions, NOTOTCO2RF = ifelse(NOTOTCO2RF < 0 | is.na(NOTOTCO2RF), 0, NOTOTCO2RF))
    emissions <- mutate(emissions, NOTOTCO2RM = ifelse(NOTOTCO2RM < 0 | is.na(NOTOTCO2RM), 0, NOTOTCO2RM))
    emissions <- mutate(emissions, NOTOTCO2MM = ifelse(NOTOTCO2MM < 0 | is.na(NOTOTCO2MM), 0, NOTOTCO2MM))
    emissions <- mutate(emissions, NOTOTCO2MF = ifelse(NOTOTCO2MF < 0 | is.na(NOTOTCO2MF), 0, NOTOTCO2MF))
    emissions <- transform(emissions, N2O_from_manure_management = NOTOTCO2AFM + NOTOTCO2AFN + NOTOTCO2AM + NOTOTCO2RF + NOTOTCO2RM + NOTOTCO2MM + NOTOTCO2MF)
    
    emissions <- mutate(emissions, NOTOTPASTUREAFM = ifelse(NOTOTPASTUREAFM < 0 | is.na(NOTOTPASTUREAFM), 0, NOTOTPASTUREAFM))
    emissions <- mutate(emissions, NOTOTPASTUREAFN = ifelse(NOTOTPASTUREAFN < 0 | is.na(NOTOTPASTUREAFN), 0, NOTOTPASTUREAFN))
    emissions <- mutate(emissions, NOTOTPASTUREAM = ifelse(NOTOTPASTUREAM < 0 | is.na(NOTOTPASTUREAM), 0, NOTOTPASTUREAM))
    emissions <- mutate(emissions, NOTOTPASTURERF = ifelse(NOTOTPASTURERF < 0 | is.na(NOTOTPASTURERF), 0, NOTOTPASTURERF))
    emissions <- mutate(emissions, NOTOTPASTURERM = ifelse(NOTOTPASTURERM < 0 | is.na(NOTOTPASTURERM), 0, NOTOTPASTURERM))
    emissions <- mutate(emissions, NOTOTPASTUREMM = ifelse(NOTOTPASTUREMM < 0 | is.na(NOTOTPASTUREMM), 0, NOTOTPASTUREMM))
    emissions <- mutate(emissions, NOTOTPASTUREMF = ifelse(NOTOTPASTUREMF < 0 | is.na(NOTOTPASTUREMF), 0, NOTOTPASTUREMF))
    emissions <- transform(emissions, N2O_from_pasture = NOTOTPASTUREAFM + NOTOTPASTUREAFN + NOTOTPASTUREAM + NOTOTPASTURERF + NOTOTPASTURERM + NOTOTPASTUREMM + NOTOTPASTUREMF)
    
    emissions <- transform(emissions, TOTAL_EMISSIONS = CH4_from_enteric_fermentation + CH4_from_manure_management + N2O_from_manure_management + N2O_from_pasture)
    emissions <- mutate(emissions, MILK_INTENSITY = ifelse(Milk_production == 0, 0, TOTAL_EMISSIONS/(Milk_production)))
    emissions <- mutate(emissions, MEAT_INTENSITY = ifelse(Meat_total == 0, 0, TOTAL_EMISSIONS/Meat_total))
    write.csv(emissions, file = paste(table_path, "emissions.csv",sep = ""))
    
    for(n in emissions_variables){
      for(x in emissions_variables1){
        if(n == "CH41CO2TOT" | n == "CH42CO2TOT"){
          inValueRaster = raster(paste(data_path_systemtrack,"Methane_emss\\",n,x, ".tif", sep = ""))
        }
        else if( n == "NOTOTCO2"){
          inValueRaster = raster(paste(data_path_systemtrack,"N2O_emss\\",n,x, ".tif", sep = ""))
        }
        else if(n=="NOTOTPASTURE"){
          if(x=="AFM"){
            inValueRaster = AFM_N2OFEEDMAN
          }
          else if(x=="AFN"){
            inValueRaster = AFN_N2OFEEDMAN
          }
          else if(x=="AM"){
            inValueRaster = AM_N2OFEEDMAN
          }
          else if(x=="RF"){
            inValueRaster = RF_N2OFEEDMAN
          }
          else if(x=="RM"){
            inValueRaster = RM_N2OFEEDMAN
          }
          else if(x=="MM"){
            inValueRaster = MM_N2OFEEDMAN
          }
          else if(x=="MF"){
            inValueRaster = MF_N2OFEEDMAN
          }
        }
        temp_value <- calc(inValueRaster, one_value_fun, progress='text')*inValueRaster
        temp_value[is.na(temp_value)] <- 0
        one_value_raster=one_value_raster+temp_value
      }
      
    } 
    writeRaster(one_value_raster, paste(table_path,"emissionestotales.tif", sep = ""), format = "GTiff", overwrite=TRUE)
    
  }
  
  ########################################
  ## RESULT MATRIX
  ########################################
  
  path_name = "results"
  dir.create(paste("results\\RESULTADOS",sep=""))
  
  combinadocarne.herd = read.csv(paste(path_name,"\\COMBINADO_CARNE\\results_tables\\herd.csv",sep = ""))
  combinadoleche.herd = read.csv(paste(path_name,"\\COMBINADO_LECHE\\results_tables\\herd.csv",sep = ""))
  empresarialcarne.herd = read.csv(paste(path_name,"\\EMPRESARIAL_CARNE\\results_tables\\herd.csv",sep = ""))
  empresarialleche.herd = read.csv(paste(path_name,"\\EMPRESARIAL_LECHE\\results_tables\\herd.csv",sep = ""))
  marginalcarne.herd = read.csv(paste(path_name,"\\MARGINAL_CARNE\\results_tables\\herd.csv",sep = ""))
  marginalleche.herd = read.csv(paste(path_name,"\\MARGINAL_LECHE\\results_tables\\herd.csv",sep = ""))
  mercantilcarne.herd = read.csv(paste(path_name,"\\MERCANTIL_CARNE\\results_tables\\herd.csv",sep = ""))
  mercantilleche.herd = read.csv(paste(path_name,"\\MERCANTIL_LECHE\\results_tables\\herd.csv",sep = ""))
  
  combinadocarne.emissions = read.csv(paste(path_name,"\\COMBINADO_CARNE\\results_tables\\emissions.csv",sep = ""))
  combinadoleche.emissions = read.csv(paste(path_name,"\\COMBINADO_LECHE\\results_tables\\emissions.csv",sep = ""))
  empresarialcarne.emissions = read.csv(paste(path_name,"\\EMPRESARIAL_CARNE\\results_tables\\emissions.csv",sep = ""))
  empresarialleche.emissions = read.csv(paste(path_name,"\\EMPRESARIAL_LECHE\\results_tables\\emissions.csv",sep = ""))
  marginalcarne.emissions = read.csv(paste(path_name,"\\MARGINAL_CARNE\\results_tables\\emissions.csv",sep = ""))
  marginalleche.emissions = read.csv(paste(path_name,"\\MARGINAL_LECHE\\results_tables\\emissions.csv",sep = ""))
  mercantilcarne.emissions = read.csv(paste(path_name,"\\MERCANTIL_CARNE\\results_tables\\emissions.csv",sep = ""))
  mercantilleche.emissions = read.csv(paste(path_name,"\\MERCANTIL_LECHE\\results_tables\\emissions.csv",sep = ""))
  
  combinadocarne = raster(paste(path_name,"\\COMBINADO_CARNE\\results_tables\\emissionestotales.tif",sep = ""))
  combinadoleche = raster(paste(path_name,"\\COMBINADO_LECHE\\results_tables\\emissionestotales.tif",sep = ""))
  empresarialcarne = raster(paste(path_name,"\\EMPRESARIAL_CARNE\\results_tables\\emissionestotales.tif",sep = ""))
  empresarialleche = raster(paste(path_name,"\\EMPRESARIAL_LECHE\\results_tables\\emissionestotales.tif",sep = ""))
  marginalcarne = raster(paste(path_name,"\\MARGINAL_CARNE\\results_tables\\emissionestotales.tif",sep = ""))
  marginalleche = raster(paste(path_name,"\\MARGINAL_LECHE\\results_tables\\emissionestotales.tif",sep = ""))
  mercantilcarne = raster(paste(path_name,"\\MERCANTIL_CARNE\\results_tables\\emissionestotales.tif",sep = ""))
  mercantilleche = raster(paste(path_name,"\\MERCANTIL_LECHE\\results_tables\\emissionestotales.tif",sep = ""))
  
  #HERD TOTAL COMPUTATION
  herd.total = rbind(combinadocarne.herd,combinadoleche.herd,empresarialcarne.herd,empresarialleche.herd,
                     marginalcarne.herd,marginalleche.herd,mercantilcarne.herd,mercantilleche.herd)
  
  write.csv(herd.total, file = paste(path_name,"\\RESULTADOS\\herd_total.csv", sep = ""))
  
  #EMISSIONS TOTAL COMPUTATION
  emissions.total = rbind(combinadocarne.emissions,combinadoleche.emissions,empresarialcarne.emissions,empresarialleche.emissions,
                          marginalcarne.emissions,marginalleche.emissions,mercantilcarne.emissions,mercantilleche.emissions)
  
  write.csv(emissions.total, file = paste(path_name,"\\RESULTADOS\\emissions_total.csv", sep = ""))
  
  #RASTER COMBINATION
  combinado = combinadocarne+combinadoleche
  empresarial = empresarialcarne+empresarialleche
  marginal = marginalcarne+marginalleche
  mercantil = mercantilcarne+mercantilleche
  
  writeRaster(combinado, paste(path_name,"\\RESULTADOS\\combinado.tif", sep = ""), format = "GTiff", overwrite=TRUE)
  writeRaster(empresarial, paste(path_name,"\\RESULTADOS\\empresarial.tif", sep = ""), format = "GTiff", overwrite=TRUE)
  writeRaster(marginal, paste(path_name,"\\RESULTADOS\\marginal.tif", sep = ""), format = "GTiff", overwrite=TRUE)
  writeRaster(mercantil, paste(path_name,"\\RESULTADOS\\mercantil.tif", sep = ""), format = "GTiff", overwrite=TRUE)

  mosaicList <- function(rasList){
    
    #Internal function to make a list of raster objects from list of files.
    ListRasters <- function(list_names) {
      raster_list <- list() # initialise the list of rasters
      for (i in 1:(length(list_names))){ 
        grd_name <- list_names[i] # list_names contains all the names of the images in .grd format
        raster_file <- raster::raster(grd_name)
      }
      raster_list <- append(raster_list, raster_file) # update raster_list at each iteration
    }
    
    #convert every raster path to a raster object and create list of the results
    raster.list <-sapply(rasList, FUN = ListRasters)
    
    # edit settings of the raster list for use in do.call and mosaic
    names(raster.list) <- NULL
    #####This function deals with overlapping areas
    raster.list$fun <- sum
    
    #run do call to implement mosaic over the list of raster objects.
    mos <- do.call(raster::mosaic, raster.list)
    
    #set crs of output
    crs(mos) <- crs(x = raster(rasList[1]))
    return(mos)
  }
  
  raster_files <- list.files(path =paste(path_name,"\\RESULTADOS\\",sep=""),pattern = ".tif$",full.names = TRUE )
  
  national_layer <- mosaicList(raster_files )
  writeRaster(national_layer, paste(path_name,"\\RESULTADOS\\total.tif", sep = ""), format = "GTiff", overwrite=TRUE)
  
}


########################################
##INPUT FILES
########################################

## CSV FILES
main_pasture_list_marginal_milk = read.csv("input_pasture_main_list_marginal_milk.csv")
main_pasture_list_marginal_meat = read.csv("input_pasture_main_list_marginal_meat.csv")
main_pasture_list_mercantil_milk = read.csv("input_pasture_main_list_mercantil_milk.csv")
main_pasture_list_mercantil_meat = read.csv("input_pasture_main_list_mercantil_meat.csv")
main_pasture_list_combinado_milk = read.csv("input_pasture_main_list_combinado_milk.csv")
main_pasture_list_combinado_meat = read.csv("input_pasture_main_list_combinado_meat.csv")
main_pasture_list_empresarial_milk = read.csv("input_pasture_main_list_empresarial_milk.csv")
main_pasture_list_empresarial_meat = read.csv("input_pasture_main_list_empresarial_meat.csv")
diet_list_marginal_milk = read.csv("input_feed_supplements_list_marginal_milk.csv")
diet_list_marginal_meat = read.csv("input_feed_supplements_list_marginal_meat.csv")
diet_list_mercantil_milk = read.csv("input_feed_supplements_list_mercantil_milk.csv")
diet_list_mercantil_meat = read.csv("input_feed_supplements_list_mercantil_meat.csv")
diet_list_combinado_milk = read.csv("input_feed_supplements_list_combinado_milk.csv")
diet_list_combinado_meat = read.csv("input_feed_supplements_list_combinado_meat.csv")
diet_list_empresarial_milk = read.csv("input_feed_supplements_list_empresarial_milk.csv")
diet_list_empresarial_meat = read.csv("input_feed_supplements_list_empresarial_meat.csv")
national_data = read.csv("input_national_data.csv")


