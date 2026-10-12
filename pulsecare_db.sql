-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 172.21.12.21    Database: pulsecare_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `AuditLog`
--

DROP TABLE IF EXISTS `AuditLog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `AuditLog` (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `staff_id` int NOT NULL,
  `action_type` enum('INSERT','UPDATE','DELETE','OVERRIDE_CDSS','VIEW_RECORD') COLLATE utf8mb4_unicode_ci NOT NULL,
  `affected_table` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `record_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `previous_values` json DEFAULT NULL,
  `new_values` json DEFAULT NULL,
  `override_justification` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`log_id`),
  KEY `fk_audit_staff` (`staff_id`),
  CONSTRAINT `fk_audit_staff` FOREIGN KEY (`staff_id`) REFERENCES `StaffMember` (`staff_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `AuditLog`
--

LOCK TABLES `AuditLog` WRITE;
/*!40000 ALTER TABLE `AuditLog` DISABLE KEYS */;
INSERT INTO `AuditLog` VALUES (1,1,'INSERT','Consultation','1','2026-10-10 18:15:10',NULL,'{\"doctor_id\": 1, \"patient_id\": 1}',NULL),(2,3,'INSERT','VitalSigns','1','2026-10-10 18:15:10',NULL,'{\"systolic_bp\": 142, \"consultation_id\": 1}',NULL),(3,1,'INSERT','Prescription','1','2026-10-10 18:15:10',NULL,'{\"presc_id\": 1, \"consultation_id\": 1}',NULL),(4,4,'UPDATE','Prescription','1','2026-10-10 18:15:10','{\"fulfillment_status\": \"Pending\"}','{\"fulfillment_status\": \"Dispensed\"}','Dispensed following pharmacist verification.'),(5,1,'OVERRIDE_CDSS','PrescriptionItem','1-6','2026-10-10 18:15:10',NULL,'{\"med_id\": 6, \"presc_id\": 1}','Clinical benefit of Diclofenac deemed to outweigh mild gastric distress risk; patient prescribed concurrent PPI gastroprotection.');
/*!40000 ALTER TABLE `AuditLog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Consultation`
--

DROP TABLE IF EXISTS `Consultation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Consultation` (
  `consultation_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int NOT NULL,
  `doctor_id` int NOT NULL,
  `consultation_datetime` datetime NOT NULL,
  `diagnostic_notes` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `preliminary_findings` text COLLATE utf8mb4_unicode_ci,
  `treatment_plan` text COLLATE utf8mb4_unicode_ci,
  `encounter_status` enum('Scheduled','In-Progress','Completed','Cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Completed',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`consultation_id`),
  KEY `fk_consultation_patient` (`patient_id`),
  KEY `fk_consultation_doctor` (`doctor_id`),
  CONSTRAINT `fk_consultation_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `StaffMember` (`staff_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_consultation_patient` FOREIGN KEY (`patient_id`) REFERENCES `Patient` (`patient_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Consultation`
--

LOCK TABLES `Consultation` WRITE;
/*!40000 ALTER TABLE `Consultation` DISABLE KEYS */;
INSERT INTO `Consultation` VALUES (1,1,1,'2026-10-01 09:30:00','Patient reports chronic fatigue and persistent joint pain.','Elevated blood pressure; mild peripheral edema.','Prescribed NSAID therapy; routine laboratory workup ordered.','Completed','2026-10-10 18:15:10'),(2,2,1,'2026-10-02 10:15:00','Recurrent lower respiratory infection with productive cough.','Coarse bilateral crackles upon chest auscultation.','Prescribe broad-spectrum antibiotic therapy.','Completed','2026-10-10 18:15:10'),(3,3,2,'2026-10-03 11:00:00','Routine diabetic and cardiovascular follow-up.','Well-controlled glycaemic status; mild hypertension noted.','Continue Metformin; initiate lipid-lowering therapy.','Completed','2026-10-10 18:15:10'),(4,5,2,'2026-10-04 14:00:00','Deep vein thrombosis routine medication review.','Stable lower limb circumference; therapeutic coagulation.','Refill Warfarin; monitor international normalized ratio (INR).','Completed','2026-10-10 18:15:10'),(5,4,1,'2026-10-05 15:30:00','Acute tension-type cephalea following occupational stress.','Normal neurological examination.','Short-course analgesic symptomatic relief.','Completed','2026-10-10 18:15:10');
/*!40000 ALTER TABLE `Consultation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DrugContraindication`
--

DROP TABLE IF EXISTS `DrugContraindication`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `DrugContraindication` (
  `drug_1_id` int NOT NULL,
  `drug_2_id` int NOT NULL,
  `severity_level` enum('Low','Moderate','Severe','Critical / Fatal') COLLATE utf8mb4_unicode_ci NOT NULL,
  `interaction_description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`drug_1_id`,`drug_2_id`),
  KEY `fk_dc_drug2` (`drug_2_id`),
  CONSTRAINT `fk_dc_drug1` FOREIGN KEY (`drug_1_id`) REFERENCES `Medication` (`med_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_dc_drug2` FOREIGN KEY (`drug_2_id`) REFERENCES `Medication` (`med_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DrugContraindication`
--

LOCK TABLES `DrugContraindication` WRITE;
/*!40000 ALTER TABLE `DrugContraindication` DISABLE KEYS */;
INSERT INTO `DrugContraindication` VALUES (3,4,'Moderate','Atorvastatin may moderately potentiate the anticoagulant effect of Warfarin; INR monitoring recommended.'),(4,6,'Severe','Concomitant use of Warfarin and Diclofenac significantly elevates gastrointestinal bleeding risk.');
/*!40000 ALTER TABLE `DrugContraindication` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Medication`
--

DROP TABLE IF EXISTS `Medication`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Medication` (
  `med_id` int NOT NULL AUTO_INCREMENT,
  `commercial_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `active_ingredient` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dosage_form` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `unit_strength` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `administration_route` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `storage_instructions` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`med_id`),
  UNIQUE KEY `uq_med_form_strength` (`commercial_name`,`dosage_form`,`unit_strength`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Medication`
--

LOCK TABLES `Medication` WRITE;
/*!40000 ALTER TABLE `Medication` DISABLE KEYS */;
INSERT INTO `Medication` VALUES (1,'Amoxil','Amoxicillin','Capsule','500mg','Oral','Store below 25C in a dry place','2026-10-10 18:15:10'),(2,'Augmentin','Amoxicillin / Clavulanate','Tablet','625mg','Oral','Store below 25C; protect from moisture','2026-10-10 18:15:10'),(3,'Lipitor','Atorvastatin','Tablet','20mg','Oral','Store at controlled room temperature','2026-10-10 18:15:10'),(4,'Warfarin Sodium','Warfarin','Tablet','5mg','Oral','Protect from light and moisture','2026-10-10 18:15:10'),(5,'Panado','Paracetamol','Tablet','500mg','Oral','Store in a cool dry place','2026-10-10 18:15:10'),(6,'Cataflam','Diclofenac Potassium','Tablet','50mg','Oral','Store below 30C','2026-10-10 18:15:10'),(7,'Glucophage','Metformin HCl','Tablet','850mg','Oral','Store at room temperature','2026-10-10 18:15:10');
/*!40000 ALTER TABLE `Medication` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Patient`
--

DROP TABLE IF EXISTS `Patient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Patient` (
  `patient_id` int NOT NULL AUTO_INCREMENT,
  `id_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_of_birth` date NOT NULL,
  `biological_sex` enum('Male','Female','Other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `residential_address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_contact_phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `registered_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`patient_id`),
  UNIQUE KEY `uq_patient_id_number` (`id_number`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Patient`
--

LOCK TABLES `Patient` WRITE;
/*!40000 ALTER TABLE `Patient` DISABLE KEYS */;
INSERT INTO `Patient` VALUES (1,'9001155023088','Sipho','Nkosi','1990-01-15','Male','14 Long Street, Cape Town','+27711234567','+27719998877','2026-10-10 18:15:10'),(2,'8505220145082','Elena','Rostova','1985-05-22','Female','42 Kloof Street, Gardens',NULL,'+27728887766','2026-10-10 18:15:10'),(3,'7811035298084','Kagiso','Mokoena','1978-11-03','Male','8 Adderley Road, Bellville','+27733456789','+27737776655','2026-10-10 18:15:10'),(4,'9508190342081','Amina','Patel','1995-08-19','Female','105 Victoria Road, Woodstock','+27744567890','+27746665544','2026-10-10 18:15:10'),(5,'6203105129087','Johannes','Botha','1962-03-10','Male','27 Voortrekker Road, Parow','+27755678901','+27755554433','2026-10-10 18:15:10');
/*!40000 ALTER TABLE `Patient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PatientAllergy`
--

DROP TABLE IF EXISTS `PatientAllergy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PatientAllergy` (
  `patient_id` int NOT NULL,
  `med_id` int NOT NULL,
  `reaction_description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reaction_severity` enum('Mild','Moderate','Severe','Anaphylactic') COLLATE utf8mb4_unicode_ci NOT NULL,
  `diagnosis_date` date NOT NULL,
  PRIMARY KEY (`patient_id`,`med_id`),
  KEY `fk_pa_medication` (`med_id`),
  CONSTRAINT `fk_pa_medication` FOREIGN KEY (`med_id`) REFERENCES `Medication` (`med_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pa_patient` FOREIGN KEY (`patient_id`) REFERENCES `Patient` (`patient_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PatientAllergy`
--

LOCK TABLES `PatientAllergy` WRITE;
/*!40000 ALTER TABLE `PatientAllergy` DISABLE KEYS */;
INSERT INTO `PatientAllergy` VALUES (1,1,'Cutaneous rash, acute urticaria, facial angioedema','Severe','2021-04-10'),(2,6,'Severe gastric erosion, epigastric distress','Moderate','2022-09-15'),(5,1,'Anaphylactic bronchospasm within 30 minutes of oral ingestion','Anaphylactic','2018-02-20');
/*!40000 ALTER TABLE `PatientAllergy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Prescription`
--

DROP TABLE IF EXISTS `Prescription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Prescription` (
  `presc_id` int NOT NULL AUTO_INCREMENT,
  `consultation_id` int NOT NULL,
  `prescribed_by_staff_id` int NOT NULL,
  `dispensed_by_pharmacist_id` int DEFAULT NULL,
  `prescription_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fulfillment_status` enum('Pending','Reviewed','Dispensed','Cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `notes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`presc_id`),
  KEY `fk_presc_consultation` (`consultation_id`),
  KEY `fk_presc_doctor` (`prescribed_by_staff_id`),
  KEY `fk_presc_pharmacist` (`dispensed_by_pharmacist_id`),
  CONSTRAINT `fk_presc_consultation` FOREIGN KEY (`consultation_id`) REFERENCES `Consultation` (`consultation_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_presc_doctor` FOREIGN KEY (`prescribed_by_staff_id`) REFERENCES `StaffMember` (`staff_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_presc_pharmacist` FOREIGN KEY (`dispensed_by_pharmacist_id`) REFERENCES `StaffMember` (`staff_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Prescription`
--

LOCK TABLES `Prescription` WRITE;
/*!40000 ALTER TABLE `Prescription` DISABLE KEYS */;
INSERT INTO `Prescription` VALUES (1,1,1,4,'2026-10-01 10:00:00','Dispensed','Patient counselled on GI protection.'),(2,2,1,4,'2026-10-02 10:45:00','Dispensed','Completed full 7-day course.'),(3,3,2,4,'2026-10-03 11:30:00','Dispensed','Monthly chronic repeat.'),(4,4,2,NULL,'2026-10-04 14:30:00','Pending','Pending pharmacist review of recent INR lab values.'),(5,5,1,4,'2026-10-05 16:00:00','Dispensed','Symptomatic pain relief.');
/*!40000 ALTER TABLE `Prescription` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PrescriptionItem`
--

DROP TABLE IF EXISTS `PrescriptionItem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PrescriptionItem` (
  `presc_id` int NOT NULL,
  `med_id` int NOT NULL,
  `dosage_instructions` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `daily_frequency` int NOT NULL,
  `quantity_ordered` int NOT NULL,
  `dispensing_status` enum('Pending','Dispensed','Substituted','Cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  PRIMARY KEY (`presc_id`,`med_id`),
  KEY `fk_pi_medication` (`med_id`),
  CONSTRAINT `fk_pi_medication` FOREIGN KEY (`med_id`) REFERENCES `Medication` (`med_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pi_prescription` FOREIGN KEY (`presc_id`) REFERENCES `Prescription` (`presc_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_daily_freq` CHECK ((`daily_frequency` > 0)),
  CONSTRAINT `chk_qty_ordered` CHECK ((`quantity_ordered` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PrescriptionItem`
--

LOCK TABLES `PrescriptionItem` WRITE;
/*!40000 ALTER TABLE `PrescriptionItem` DISABLE KEYS */;
INSERT INTO `PrescriptionItem` VALUES (1,6,'Take 1 tablet after meals twice daily',2,20,'Dispensed'),(2,2,'Take 1 tablet every 12 hours with food',2,14,'Dispensed'),(3,3,'Take 1 tablet once daily at bedtime',1,30,'Dispensed'),(3,7,'Take 1 tablet twice daily with meals',2,60,'Dispensed'),(4,4,'Take 1 tablet daily at 18:00 as per INR dosing',1,30,'Pending'),(5,5,'Take 2 tablets every 6 hours as needed for headache',4,24,'Dispensed');
/*!40000 ALTER TABLE `PrescriptionItem` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `StaffMember`
--

DROP TABLE IF EXISTS `StaffMember`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `StaffMember` (
  `staff_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('Doctor','Nurse','Pharmacist','Administrator') COLLATE utf8mb4_unicode_ci NOT NULL,
  `license_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`staff_id`),
  UNIQUE KEY `uq_staff_license` (`license_number`),
  UNIQUE KEY `uq_staff_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `StaffMember`
--

LOCK TABLES `StaffMember` WRITE;
/*!40000 ALTER TABLE `StaffMember` DISABLE KEYS */;
INSERT INTO `StaffMember` VALUES (1,'Thabo','Molefe','Doctor','HPCSA-MED-101','t.molefe@pulsecare.co.za','+27821112233','$2b$12$e8YkYk4qR3...','2026-10-10 18:15:10'),(2,'Sarah','Jenkins','Doctor','HPCSA-MED-102','s.jenkins@pulsecare.co.za','+27824445566','$2b$12$o9PzYk4qR3...','2026-10-10 18:15:10'),(3,'Nomsa','Dlamini','Nurse','SANC-NUR-201','n.dlamini@pulsecare.co.za','+27835556677','$2b$12$a1BxYk4qR3...','2026-10-10 18:15:10'),(4,'David','VanDerMerwe','Pharmacist','SAPC-PHARM-301','d.vandermerwe@pulsecare.co.za','+27846667788','$2b$12$q7WzYk4qR3...','2026-10-10 18:15:10'),(5,'Zukiswa','Sithole','Administrator','ADMIN-SYS-001','z.sithole@pulsecare.co.za','+27857778899','$2b$12$m3KxYk4qR3...','2026-10-10 18:15:10');
/*!40000 ALTER TABLE `StaffMember` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `VitalSigns`
--

DROP TABLE IF EXISTS `VitalSigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `VitalSigns` (
  `vital_id` int NOT NULL AUTO_INCREMENT,
  `consultation_id` int NOT NULL,
  `recorded_by_staff_id` int NOT NULL,
  `recorded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `systolic_bp` int NOT NULL,
  `diastolic_bp` int NOT NULL,
  `heart_rate_bpm` int NOT NULL,
  `body_temperature_celsius` decimal(4,2) NOT NULL,
  `respiratory_rate` int NOT NULL,
  `oxygen_saturation_pct` decimal(5,2) NOT NULL,
  PRIMARY KEY (`vital_id`),
  UNIQUE KEY `uq_consultation_vitals` (`consultation_id`),
  KEY `fk_vitals_recorder` (`recorded_by_staff_id`),
  CONSTRAINT `fk_vitals_consultation` FOREIGN KEY (`consultation_id`) REFERENCES `Consultation` (`consultation_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_vitals_recorder` FOREIGN KEY (`recorded_by_staff_id`) REFERENCES `StaffMember` (`staff_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_body_temp` CHECK ((`body_temperature_celsius` between 32.0 and 44.0)),
  CONSTRAINT `chk_diastolic_bp` CHECK ((`diastolic_bp` between 30 and 160)),
  CONSTRAINT `chk_heart_rate` CHECK ((`heart_rate_bpm` between 30 and 250)),
  CONSTRAINT `chk_resp_rate` CHECK ((`respiratory_rate` between 8 and 60)),
  CONSTRAINT `chk_spo2` CHECK ((`oxygen_saturation_pct` between 50.00 and 100.00)),
  CONSTRAINT `chk_systolic_bp` CHECK ((`systolic_bp` between 50 and 260))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `VitalSigns`
--

LOCK TABLES `VitalSigns` WRITE;
/*!40000 ALTER TABLE `VitalSigns` DISABLE KEYS */;
INSERT INTO `VitalSigns` VALUES (1,1,3,'2026-10-10 18:15:10',142,92,78,36.80,16,98.00),(2,2,3,'2026-10-10 18:15:10',118,76,88,38.40,22,94.50),(3,3,3,'2026-10-10 18:15:10',138,86,72,36.60,15,99.00),(4,4,3,'2026-10-10 18:15:10',130,82,68,36.70,14,98.50),(5,5,3,'2026-10-10 18:15:10',122,80,74,36.90,16,99.00);
/*!40000 ALTER TABLE `VitalSigns` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-10 22:42:02
