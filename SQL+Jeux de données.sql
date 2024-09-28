-- phpMyAdmin SQL Dump
-- version 5.1.3
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost
-- Généré le : lun. 27 mars 2023 à 09:47
-- Version du serveur : 10.5.12-MariaDB-0+deb11u1
-- Version de PHP : 7.4.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`ztaconro0`@`%` PROCEDURE `actu_now` ()   BEGIN
DECLARE ID_DER INT DEFAULT 0;
DECLARE AUTEUR_DER TEXT;
DECLARE TEXTE TEXT;
SET ID_DER := (SELECT id_dernier_concours());
SET AUTEUR_DER := (SELECT CPT_idCompte FROM t_actualite_ACT JOIN t_compte_organisateur_ORG USING(CPT_idCompte) JOIN t_compte_CPT USING(CPT_idCompte) ORDER BY CPT_idCompte DESC LIMIT 1);
SET TEXTE := (SELECT GROUP_CONCAT(CCS_idConcours, ' ', CCS_dateDebut, ' ', CCS_intro) AS TEXTE FROM t_concours_CCS WHERE CCS_idConcours = ID_DER);
INSERT INTO t_actualite_ACT(ACT_titreActualite, ACT_message, ACT_dateActualite, ACT_activation, CPT_idCompte) VALUES ('test',TEXTE,CURDATE(),'O',AUTEUR_DER);
END$$

CREATE DEFINER=`ztaconro0`@`%` PROCEDURE `donne_age` (IN `VALEUR` INT)   BEGIN
SELECT pfl_id, donne_mon_age(VALEUR);
END$$

--
-- Fonctions
--
CREATE DEFINER=`ztaconro0`@`%` FUNCTION `donner_categorie` (`identifiantConcours` INT) RETURNS TEXT CHARSET utf8mb4  BEGIN
DECLARE DONNER_CATEGORIE TEXT;
SET DONNER_CATEGORIE := (SELECT GROUP_CONCAT(CAT_nom, ' ') FROM t_concours_CCS JOIN t_possede_PDE USING(CCS_idConcours) JOIN t_categorie_CAT USING(CAT_idCategorie) WHERE CCS_idConcours = identifiantConcours);
RETURN DONNER_CATEGORIE;
END$$

CREATE DEFINER=`ztaconro0`@`%` FUNCTION `donner_documents` (`identifiantParticipant` INT) RETURNS TEXT CHARSET utf8mb4  BEGIN
DECLARE DOCUMENTS TEXT;
SET DOCUMENTS := (SELECT GROUP_CONCAT(DCT_chemin,' ') FROM t_participant_PTT JOIN t_document_DCT USING(PTT_idParticipant) WHERE PTT_idParticipant = identifiantParticipant);
RETURN DOCUMENTS;
END$$

CREATE DEFINER=`ztaconro0`@`%` FUNCTION `donner_jury` (`identifiantConcours` INT) RETURNS TEXT CHARSET utf8mb4  BEGIN
DECLARE DONNER_JURY TEXT;
SET DONNER_JURY := (SELECT GROUP_CONCAT(JURY.CPT_nom, ' ', JURY.CPT_prenom, ' ', ' -- Sa discipline : ',JRY_discipline, ' -- ') FROM t_concours_CCS 
                    				JOIN t_siege_SGE ON t_concours_CCS.CCS_idConcours = t_siege_SGE.CCS_idConcours
                                    JOIN t_compte_jury_JRY ON t_siege_SGE.CPT_idCompte = t_compte_jury_JRY.CPT_idCompte
                                    JOIN t_compte_CPT JURY ON JURY.CPT_idCompte = t_compte_jury_JRY.CPT_idCompte
                    				WHERE t_concours_CCS.CCS_idConcours = identifiantConcours);
RETURN DONNER_JURY;
END$$

CREATE DEFINER=`ztaconro0`@`%` FUNCTION `donner_nbCandidature` (`identifiantConcours` INT) RETURNS INT(11)  BEGIN
DECLARE NB_CANDIDATURE INT;
SET NB_CANDIDATURE := (SELECT COUNT(PTT_idParticipant) AS NbCandidatures 
                                   FROM t_concours_CCS 
                                   JOIN t_participant_PTT USING(CCS_idConcours) 
                                   WHERE CCS_idConcours = identifiantConcours);
RETURN NB_CANDIDATURE;
END$$

CREATE DEFINER=`ztaconro0`@`%` FUNCTION `donner_role` (`pseudo` TEXT) RETURNS TEXT CHARSET utf8mb4  BEGIN
DECLARE DONNER_JURY TEXT;
SET DONNER_JURY := (SELECT CPT_pseudo FROM t_compte_CPT JOIN t_compte_jury_JRY USING(CPT_idCompte) WHERE CPT_pseudo = pseudo );
IF ( DONNER_JURY = pseudo) THEN
RETURN 'J';
ELSE
RETURN 'O';
END IF;
END$$

CREATE DEFINER=`ztaconro0`@`%` FUNCTION `id_dernier_compte` () RETURNS INT(11)  BEGIN
DECLARE IDCOMPTE INT;
SET IDCOMPTE := (SELECT CPT_idCompte FROM t_compte_CPT ORDER BY CPT_idCompte DESC LIMIT 1);
RETURN IDCOMPTE;
END$$

CREATE DEFINER=`ztaconro0`@`%` FUNCTION `id_dernier_concours` () RETURNS INT(11)  BEGIN
DECLARE IDDER INT DEFAULT 0;
 SET IDDER := (SELECT CCS_idConcours FROM t_concours_CCS ORDER BY CCS_idConcours DESC LIMIT 1);
 RETURN IDDER;
END$$

CREATE DEFINER=`ztaconro0`@`%` FUNCTION `NbDocuments` (`identifiantParticipant` INT) RETURNS INT(11)  BEGIN
DECLARE NB_DOC INT DEFAULT NULL;
SET NB_DOC := (SELECT COUNT(DCT_idDocument) FROM t_document_DCT WHERE PTT_idParticipant = identifiantParticipant);
RETURN NB_DOC;
END$$

CREATE DEFINER=`ztaconro0`@`%` FUNCTION `phase_concours` (`identifiantConcours` INT) RETURNS TEXT CHARSET utf8mb4  BEGIN
DECLARE DATE_DEBUT DATE;
DECLARE DATE_JOURPRE DATE;
DECLARE DATE_FINALE DATE;
DECLARE DATE_FIN DATE;
SET DATE_DEBUT := (SELECT CCS_dateDebut FROM t_concours_CCS WHERE CCS_idConcours = identifiantConcours);
SET DATE_JOURPRE := (SELECT CCS_dateJoursPreselection FROM t_concours_CCS WHERE CCS_idConcours = identifiantConcours);
SET DATE_FINALE := (SELECT CCS_dateFinale FROM t_concours_CCS WHERE CCS_idConcours = identifiantConcours);
SET DATE_FIN := (SELECT CCS_dateFin FROM t_concours_CCS WHERE CCS_idConcours = identifiantConcours);
IF (CURDATE()<DATE_DEBUT) THEN
RETURN 'A Venir';
ELSEIF (CURDATE()<DATE_JOURPRE) THEN
RETURN 'Phase de candidatures !';
ELSEIF (CURDATE()<DATE_FINALE) THEN
RETURN 'Phase de sélections !';
ELSEIF (CURDATE()<DATE_FIN) THEN
RETURN 'Phase finale du concours !';
ELSE
RETURN 'Concours terminé !';
END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `t_actualite_ACT`
--

CREATE TABLE `t_actualite_ACT` (
  `ACT_idActualite` int(11) NOT NULL,
  `ACT_titreActualite` varchar(80) DEFAULT NULL,
  `ACT_message` varchar(500) DEFAULT NULL,
  `ACT_dateActualite` date DEFAULT NULL,
  `ACT_activation` char(1) DEFAULT NULL,
  `CPT_idCompte` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_actualite_ACT`
--

INSERT INTO `t_actualite_ACT` (`ACT_idActualite`, `ACT_titreActualite`, `ACT_message`, `ACT_dateActualite`, `ACT_activation`, `CPT_idCompte`) VALUES
(1, 'Illuminations de Noël | date de commencement', 'Nous vous informons que vous votre concours intitulé \"Illuminations de Noël\" commencera à partir du 28 Février !', '2022-02-16', 'O', 5),
(2, 'Changement date des préselection concours \"Le plus bel Extérieur\"', 'Voici les changements de date des préselection concours \"Le plus bel Extérieur\"', '2021-11-02', 'N', 5),
(3, 'Ajout délais', 'Ajout délais supplémentaire pour les candidatures du concours \" Le plus bel intérieur \"', '2023-02-16', 'O', 7),
(7, 'Test Titre concours déco extérieur', '4 2021-01-23 10:00:00 C\'est un concours pour les décorations de noël extérieur', '2023-02-14', 'O', 7),
(9, 'test', '7 2022-12-12 00:00:00 ceci est un test', '2023-02-15', 'O', 7),
(10, 'test', '8 2023-02-26 18:37:00 Ce concours regroupe la fine fleur des décorateurs d\'intérieur afin d\'élire la plus belle chambre grâce à notre sélection de jury aux petits oignons.', '2023-02-27', 'O', 7),
(11, 'test', '9 2022-12-12 00:00:00 ceci est un test', '2023-03-03', 'O', 7),
(12, 'Problème ajout participant', 'Bonjour, nous constatons un problème lors de l\'ajout des participants. Merci de le rectifier', '2023-03-27', 'N', 5),
(13, 'Ajustement documents pour les candidats', 'Bonjour, je souhait vous faire part d\'un changement dans les règles pour soumettre les documents pour un candidat', '2023-03-01', 'N', 6),
(14, 'test', '10 2023-03-01 01:35:12 Bienvenue dans le concours des plus beau sapins de Noël édition 2023', '2023-03-27', 'O', 7),
(15, 'test', '11 2022-09-14 01:49:03 Bienvenue dans le concours des plus beau sapins de Noël édition 2022', '2023-03-27', 'O', 7);

-- --------------------------------------------------------

--
-- Structure de la table `t_categorie_CAT`
--

CREATE TABLE `t_categorie_CAT` (
  `CAT_idCategorie` int(11) NOT NULL,
  `CAT_nom` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_categorie_CAT`
--

INSERT INTO `t_categorie_CAT` (`CAT_idCategorie`, `CAT_nom`) VALUES
(1, 'Amateur'),
(2, 'Semi-Amateur'),
(3, 'Professionnel'),
(4, 'Suprême'),
(5, 'Légendaire');

-- --------------------------------------------------------

--
-- Structure de la table `t_compte_CPT`
--

CREATE TABLE `t_compte_CPT` (
  `CPT_idCompte` int(11) NOT NULL,
  `CPT_pseudo` varchar(20) NOT NULL,
  `CPT_motDePasse` char(64) NOT NULL,
  `CPT_nom` varchar(80) NOT NULL,
  `CPT_prenom` varchar(80) NOT NULL,
  `CPT_mail` varchar(300) DEFAULT NULL,
  `CPT_activation` char(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_compte_CPT`
--

INSERT INTO `t_compte_CPT` (`CPT_idCompte`, `CPT_pseudo`, `CPT_motDePasse`, `CPT_nom`, `CPT_prenom`, `CPT_mail`, `CPT_activation`) VALUES
(1, 'Organisateur', '33ba0c9df23b910221af3406dc454a7e5b6670eb28a350c252a40f226a0cda6e', 'Tacon', 'Romain', 'Organisateur@gmail.com', 'O'),
(2, 'Rogury', '97f3b9287e2da5e04e9f6d4abf6454783a37bb5413feeb067132475b6dd01f3b', 'Jury', 'Roger', 'rogury@lemail.fr', 'O'),
(3, 'ZinedinePasta', 'dae8d8ec2ad5bf38867f50bc81d0d7e44b9767113d5c350eb9f32aa3b66cf19f', 'PestoJury', 'PatesO', 'aimelespates@pastamail.it', 'O'),
(4, 'Clarissa', 'dae8d8ec2ad5bf38867f50bc81d0d7e44b9767113d5c350eb9f32aa3b66cf19f', 'Sauce', 'Clarissa', 'clarissa@gmail.com', 'O'),
(5, 'Patrick', 'dae8d8ec2ad5bf38867f50bc81d0d7e44b9767113d5c350eb9f32aa3b66cf19f', 'Safty', 'Patrick', 'Safty@minimails.fr', 'O'),
(6, 'Salvador', 'dae8d8ec2ad5bf38867f50bc81d0d7e44b9767113d5c350eb9f32aa3b66cf19f', 'Salvador', 'Spark', 'spark.salvador@gmail.com', 'O'),
(7, 'Ferguson', 'dae8d8ec2ad5bf38867f50bc81d0d7e44b9767113d5c350eb9f32aa3b66cf19f', 'Fergus', 'Alexia', 'fergus.manchester@mail.fr', 'O'),
(8, 'Lone Wolf', 'dae8d8ec2ad5bf38867f50bc81d0d7e44b9767113d5c350eb9f32aa3b66cf19f', 'Welch', 'Leta', 'lonewolf@outlook.com', 'O'),
(9, 'Stelling', 'dae8d8ec2ad5bf38867f50bc81d0d7e44b9767113d5c350eb9f32aa3b66cf19f', 'Chapman', 'Jim', 'chapi@gmail.com', 'O'),
(12, 'AdminInfos', 'dae8d8ec2ad5bf38867f50bc81d0d7e44b9767113d5c350eb9f32aa3b66cf19f', 'Doléron', 'Louis', 'louis@yopmail.com', 'O'),
(13, 'MembreJuryInfos', 'dae8d8ec2ad5bf38867f50bc81d0d7e44b9767113d5c350eb9f32aa3b66cf19f', 'Callster', 'Jeanna', 'callster@yopmail.com', 'N'),
(43, 'Baptista', 'dae8d8ec2ad5bf38867f50bc81d0d7e44b9767113d5c350eb9f32aa3b66cf19f', 'LaFarge', 'Baptista', 'baptistamail@gmail.com', 'O');

-- --------------------------------------------------------

--
-- Structure de la table `t_compte_jury_JRY`
--

CREATE TABLE `t_compte_jury_JRY` (
  `CPT_idCompte` int(11) NOT NULL,
  `JRY_discipline` varchar(80) DEFAULT NULL,
  `JRY_url` varchar(300) DEFAULT NULL,
  `JRY_bio` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_compte_jury_JRY`
--

INSERT INTO `t_compte_jury_JRY` (`CPT_idCompte`, `JRY_discipline`, `JRY_url`, `JRY_bio`) VALUES
(2, 'Maison', 'www.google.fr', 'Je suis Roger le jury intransigeant. Alors ne faites pas d\'erreurs ou vous serez sanctionné !'),
(3, 'Maison', 'www.google.com', 'Bonjour, je suis Zinedine. Montrez de quoi vous êtes capable !'),
(4, 'Maison', 'www.twitter.com', 'Je suis Clarissa, Fan et amatrice de décoration extérieur. Je suis là pour juger vos œuvres. Faites nous rêver ! '),
(8, 'Maison', 'www.stan.com', 'C\'est Stan le Boss!'),
(9, 'Maison', 'www.stelling.com', 'Le story tetling c\'est ici '),
(13, 'Ceci est une discipline', 'url', 'Ceci est ma bio'),
(43, 'Maison', 'youtube.com', 'Maison');

-- --------------------------------------------------------

--
-- Structure de la table `t_compte_organisateur_ORG`
--

CREATE TABLE `t_compte_organisateur_ORG` (
  `CPT_idCompte` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_compte_organisateur_ORG`
--

INSERT INTO `t_compte_organisateur_ORG` (`CPT_idCompte`) VALUES
(5),
(6),
(7),
(12);

-- --------------------------------------------------------

--
-- Structure de la table `t_concours_CCS`
--

CREATE TABLE `t_concours_CCS` (
  `CCS_idConcours` int(11) NOT NULL,
  `CCS_nomConcours` varchar(80) NOT NULL,
  `CCS_intro` varchar(255) DEFAULT NULL,
  `CCS_imageConcours` varchar(300) DEFAULT NULL,
  `CCS_dateDebut` datetime DEFAULT NULL,
  `CCS_dateJoursPreselection` date DEFAULT NULL,
  `CCS_dateFinale` date DEFAULT NULL,
  `CCS_dateFin` date DEFAULT NULL,
  `CPT_idCompte` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_concours_CCS`
--

INSERT INTO `t_concours_CCS` (`CCS_idConcours`, `CCS_nomConcours`, `CCS_intro`, `CCS_imageConcours`, `CCS_dateDebut`, `CCS_dateJoursPreselection`, `CCS_dateFinale`, `CCS_dateFin`, `CPT_idCompte`) VALUES
(1, 'Illuminations  de Noël 2023', 'C\'est un concours pour les décorations de noël extérieur', 'Concours-de-Noel-2023.jpg', '2023-02-28 09:00:00', '2023-03-20', '2023-03-21', '2023-03-30', 5),
(2, 'Le plus bel extérieur', 'C\'est un concours qui définit le plus beau jardin', 'concours-exterieur.jpg', '2023-02-04 18:00:00', '2023-02-15', '2023-02-25', '2023-02-28', 6),
(3, 'Le plus bel intérieur', 'C\'est un concours qui définit le plus beau jardin', 'concours-interieur.jpg', '2023-03-09 11:06:00', '2023-03-14', '2023-03-27', '2023-06-28', 7),
(4, 'Illuminations  de Noël 2021', 'C\'est un concours pour les décorations de noël extérieur', 'concour-noel-2021.png', '2021-01-23 10:00:00', '2021-01-13', '2021-02-03', '2021-02-17', 6),
(7, 'Concours pour le test', 'ceci est un test', 'test.webp', '2022-12-12 00:00:00', '2022-12-15', '2023-03-11', '2023-03-23', 6),
(8, 'Plus beau design de chambre 2023', 'Ce concours regroupe la fine fleur des décorateurs d\'intérieur afin d\'élire la plus belle chambre grâce à notre sélection de jury aux petits oignons.', 'chambre-concours.jpg', '2023-02-26 18:37:00', '2023-02-22', '2023-03-01', '2023-03-04', 7),
(9, 'test', 'ceci est un test', 'test.webp', '2022-12-12 00:00:00', '2022-12-15', '2022-12-17', '2022-12-18', 6),
(10, 'Le plus beau sapin de Noël 2023', 'Bienvenue dans le concours des plus beau sapins de Noël édition 2023', 'sapin.jpg', '2023-03-01 01:35:12', '2023-03-29', '2023-04-12', '2023-04-14', 7),
(11, 'Le plus beau sapin de Noël 2022', 'Bienvenue dans le concours des plus beau sapins de Noël édition 2022', 'sapin.jpg', '2022-09-14 01:49:03', '2022-11-10', '2023-02-22', '2023-03-29', 5);

--
-- Déclencheurs `t_concours_CCS`
--
DELIMITER $$
CREATE TRIGGER `ajout_actu_au_concours` AFTER INSERT ON `t_concours_CCS` FOR EACH ROW BEGIN
CALL actu_now();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `t_document_DCT`
--

CREATE TABLE `t_document_DCT` (
  `DCT_idDocument` int(11) NOT NULL,
  `DCT_chemin` varchar(300) DEFAULT NULL,
  `DCT_type` varchar(45) DEFAULT NULL,
  `PTT_idParticipant` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_document_DCT`
--

INSERT INTO `t_document_DCT` (`DCT_idDocument`, `DCT_chemin`, `DCT_type`, `PTT_idParticipant`) VALUES
(1, 'maison.pdf', 'pdf', 4),
(2, 'maison1.jpg', 'image', 5),
(3, 'maison2.jpg', 'image', 6),
(4, 'maison3.jpg', 'Img', 4),
(5, 'illumination.jpg', 'image', 7),
(6, 'la-verriere-photo-decoration-de-noel.jpg', 'image', 4),
(7, 'maison4.jpg', 'image', 7),
(12, 'maison-exterieur.jpg', 'image', 16),
(13, 'jardin.webp', 'image', 16),
(14, 'amenagement-jardin.jpg', 'image', 16),
(15, 'j3.webp', 'image', 17),
(16, 'bois.jpg', 'image', 17);

-- --------------------------------------------------------

--
-- Structure de la table `t_message_MSG`
--

CREATE TABLE `t_message_MSG` (
  `MSG_idMessage` int(11) NOT NULL,
  `MSG_texte` varchar(500) DEFAULT NULL,
  `MSG_date` datetime DEFAULT NULL,
  `SJT_idSujet` int(11) NOT NULL,
  `CPT_idCompte` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_message_MSG`
--

INSERT INTO `t_message_MSG` (`MSG_idMessage`, `MSG_texte`, `MSG_date`, `SJT_idSujet`, `CPT_idCompte`) VALUES
(1, 'Nous devrions peut-être se concentrer sur la uniformité de l\'œuvre plutôt que de juger sur le nombre de décoration en elle-même.', '2023-02-04 11:02:32', 1, 3),
(2, 'J\'aimerais qu\'on change les dates du concours car je pars en vacances aux Seychelles à cette période', '2022-11-02 00:00:00', 3, 3),
(3, 'Je tiens à vous informer du trop faible nombre de participants pour le concours \" Le plus bel intérieur\". Que devrions-nous faire ? ', '2023-01-18 17:07:53', 2, 4);

-- --------------------------------------------------------

--
-- Structure de la table `t_note_NTE`
--

CREATE TABLE `t_note_NTE` (
  `CPT_idCompte` int(11) NOT NULL,
  `PTT_idParticipant` int(11) NOT NULL,
  `NTE_note` int(11) DEFAULT NULL,
  `NTE_dateNote` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_note_NTE`
--

INSERT INTO `t_note_NTE` (`CPT_idCompte`, `PTT_idParticipant`, `NTE_note`, `NTE_dateNote`) VALUES
(2, 4, 12, '2022-12-24 17:03:09'),
(2, 5, 14, '2022-12-24 17:03:09'),
(2, 6, 18, '2022-12-24 17:04:23'),
(8, 4, 15, '2023-02-27 19:02:44');

-- --------------------------------------------------------

--
-- Structure de la table `t_participant_PTT`
--

CREATE TABLE `t_participant_PTT` (
  `PTT_idParticipant` int(11) NOT NULL,
  `PTT_mail` varchar(300) NOT NULL,
  `PTT_codeInscription` varchar(20) DEFAULT NULL,
  `PTT_codeIdentification` char(8) DEFAULT NULL,
  `PTT_nom` varchar(80) NOT NULL,
  `PTT_prenom` varchar(80) NOT NULL,
  `PTT_statutParticipant` char(1) DEFAULT NULL,
  `PTT_dateInscription` date DEFAULT NULL,
  `CAT_idCategorie` int(11) NOT NULL,
  `CCS_idConcours` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_participant_PTT`
--

INSERT INTO `t_participant_PTT` (`PTT_idParticipant`, `PTT_mail`, `PTT_codeInscription`, `PTT_codeIdentification`, `PTT_nom`, `PTT_prenom`, `PTT_statutParticipant`, `PTT_dateInscription`, `CAT_idCategorie`, `CCS_idConcours`) VALUES
(1, 'serenity@gmail.com', '78789693698585412362', '00004444', 'La Terreur', 'Joy', 'P', '2023-02-28', 1, 1),
(2, 'anthoSpecialiste@gmail.com', '15155858262635594850', '11003355', 'Specialiste', 'Antho', 'P', '2023-02-28', 3, 1),
(3, 'letavernier@gmail.com', '58586963964879200300', '33669854', 'laChips', 'Jack', 'S', '2023-03-01', 2, 1),
(4, 'participant1@gmail.com', '0000256911122658492A', '56655665', 'part1', 'jean', 'S', '2023-03-01', 1, 1),
(5, 'participant2@gmail.com', '00333336669988551452', '48480000', 'part2', 'Lili', 'P', '2023-03-02', 3, 1),
(6, 'participant3@gmail.com', '55669332001485658895', '00255889', 'part3', 'Rémy', 'N', '2023-03-02', 2, 1),
(7, 'victoria.hunter@example.com', '88885545654115369851', '12589637', 'Hunter', 'Victoria', 'N', '2023-02-28', 1, 1),
(8, 'jeffrey.sanchez@example.com', '11115545654115369822', '56898989', 'Sanchez', 'Jeffrey', 'F', '2023-02-28', 1, 1),
(9, 'arianna.garza@example.com', '82225545654115369333', '11125639', 'Garza', 'Arianna', 'F', '2023-03-01', 2, 1),
(10, 'virgil.arnold@example.com', '22225545654115369851', '44569889', 'Arnold', 'Virgil', 'F', '2023-03-01', 2, 1),
(11, 'jessica.rodriquez@example.com', '89861156484115369851', '22266695', 'Rodriquez', 'Jessica', 'P', '2023-02-01', 3, 1),
(12, 'jeff.burns@example.com', '82225545654115369851', '77866359', 'Burns', 'Jeff', 'P', '2023-02-02', 3, 1),
(14, 'dennis.flores@example.com', '22233333444888899999', '89898933', 'Flores', 'Dennis ', 'P', '2021-01-11', 3, 4),
(15, 'melvin.rodriquez@example.com\r\n\r\n', '55554141555541419999', '55554141', 'Rodriquez', 'Melvin ', 'F', '2021-01-10', 3, 4),
(16, 'dwight.elliott@example.com', '42444646424446465555', '42444646', 'Elliott', 'Dwight ', 'P', '2023-02-13', 1, 2),
(17, 'rachel.jimenez@example.com', '333751233375127777', '3337512', 'Jimenez', 'Rachel ', 'F', '2023-02-13', 1, 2),
(31, 'ronnie.ray@example.com', 'TRTR4065787878TRTRAA', '42588511', 'Ray', 'Ronnie', 'F', '2022-09-30', 4, 11),
(32, 'darlene.gray@example.com', 'AAAA858569694120AA30', '12456366', 'Gray', 'Darlene', 'F', '2022-10-02', 5, 11),
(33, 'christine.howard@example.com', 'Z12145289635478ZADF7', '10104545', 'Howard', 'Christine', 'S', '2022-10-03', 4, 11),
(34, 'felix.powell@example.com', 'TTTT4578963201456879', '14442200', 'Powell', 'Felix', 'S', '2022-10-04', 5, 11),
(35, 'joe.stevens@example.com', 'AAQQPMMM7814AA5689BB', '44556633', 'Stevens', 'Joe', 'S', '2023-03-04', 2, 10),
(36, 'terrence.mason@example.com', 'UU1212787841AATHFE30', '75999310', 'Mason', 'Terrence', 'S', '2023-03-04', 3, 10),
(37, 'elmer.stanley@example.com', 'QQSSQQSSQQSS11111111', '77452201', 'Stanley', 'Elmer', 'S', '2023-03-04', 1, 10);

-- --------------------------------------------------------

--
-- Structure de la table `t_possede_PDE`
--

CREATE TABLE `t_possede_PDE` (
  `CCS_idConcours` int(11) NOT NULL,
  `CAT_idCategorie` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_possede_PDE`
--

INSERT INTO `t_possede_PDE` (`CCS_idConcours`, `CAT_idCategorie`) VALUES
(1, 1),
(1, 2),
(1, 3),
(4, 1),
(4, 2),
(4, 3),
(10, 1),
(10, 2),
(10, 3),
(11, 4),
(11, 5);

-- --------------------------------------------------------

--
-- Structure de la table `t_siege_SGE`
--

CREATE TABLE `t_siege_SGE` (
  `CPT_idCompte` int(11) NOT NULL,
  `CCS_idConcours` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_siege_SGE`
--

INSERT INTO `t_siege_SGE` (`CPT_idCompte`, `CCS_idConcours`) VALUES
(2, 1),
(2, 4),
(2, 11),
(3, 1),
(3, 4),
(3, 10),
(3, 11),
(4, 1),
(4, 4),
(8, 4),
(8, 11),
(9, 4),
(9, 11),
(43, 10);

-- --------------------------------------------------------

--
-- Structure de la table `t_sujet_SJT`
--

CREATE TABLE `t_sujet_SJT` (
  `SJT_idSujet` int(11) NOT NULL,
  `SJT_texteSujet` varchar(200) DEFAULT NULL,
  `CCS_idConcours` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `t_sujet_SJT`
--

INSERT INTO `t_sujet_SJT` (`SJT_idSujet`, `SJT_texteSujet`, `CCS_idConcours`) VALUES
(1, 'Critères Jugement', 1),
(2, 'Nombre de candidatures trop faible', 2),
(3, 'Demande ajustement des dates car je pars en vacances', 3);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `t_actualite_ACT`
--
ALTER TABLE `t_actualite_ACT`
  ADD PRIMARY KEY (`ACT_idActualite`),
  ADD KEY `fk_t_actualite_act_t_compte_organisateur_org1_idx` (`CPT_idCompte`);

--
-- Index pour la table `t_categorie_CAT`
--
ALTER TABLE `t_categorie_CAT`
  ADD PRIMARY KEY (`CAT_idCategorie`);

--
-- Index pour la table `t_compte_CPT`
--
ALTER TABLE `t_compte_CPT`
  ADD PRIMARY KEY (`CPT_idCompte`),
  ADD UNIQUE KEY `CPT_pseudo` (`CPT_pseudo`);

--
-- Index pour la table `t_compte_jury_JRY`
--
ALTER TABLE `t_compte_jury_JRY`
  ADD PRIMARY KEY (`CPT_idCompte`),
  ADD KEY `fk_t_compte_jury_jry_t_compte_cpt_idx` (`CPT_idCompte`);

--
-- Index pour la table `t_compte_organisateur_ORG`
--
ALTER TABLE `t_compte_organisateur_ORG`
  ADD PRIMARY KEY (`CPT_idCompte`),
  ADD KEY `fk_t_compte_organisateur_org_t_compte_cpt1_idx` (`CPT_idCompte`);

--
-- Index pour la table `t_concours_CCS`
--
ALTER TABLE `t_concours_CCS`
  ADD PRIMARY KEY (`CCS_idConcours`),
  ADD KEY `fk_t_concours_ccs_t_compte_organisateur_org1_idx` (`CPT_idCompte`);

--
-- Index pour la table `t_document_DCT`
--
ALTER TABLE `t_document_DCT`
  ADD PRIMARY KEY (`DCT_idDocument`),
  ADD KEY `fk_t_document_dct_t_participant_ptt1_idx` (`PTT_idParticipant`);

--
-- Index pour la table `t_message_MSG`
--
ALTER TABLE `t_message_MSG`
  ADD PRIMARY KEY (`MSG_idMessage`),
  ADD KEY `fk_t_message_msg_t_sujet_sjt1_idx` (`SJT_idSujet`),
  ADD KEY `fk_t_message_msg_t_compte_jury_jry1_idx` (`CPT_idCompte`);

--
-- Index pour la table `t_note_NTE`
--
ALTER TABLE `t_note_NTE`
  ADD PRIMARY KEY (`CPT_idCompte`,`PTT_idParticipant`),
  ADD KEY `fk_t_compte_jury_jry_has_t_participant_ptt_t_participant_pt_idx` (`PTT_idParticipant`),
  ADD KEY `fk_t_compte_jury_jry_has_t_participant_ptt_t_compte_jury_jr_idx` (`CPT_idCompte`);

--
-- Index pour la table `t_participant_PTT`
--
ALTER TABLE `t_participant_PTT`
  ADD PRIMARY KEY (`PTT_idParticipant`),
  ADD UNIQUE KEY `ptt_codeInscription_UNIQUE` (`PTT_codeInscription`),
  ADD KEY `fk_t_participant_ptt_t_categorie_cat1_idx` (`CAT_idCategorie`),
  ADD KEY `fk_t_participant_ptt_t_concours_ccs1_idx` (`CCS_idConcours`);

--
-- Index pour la table `t_possede_PDE`
--
ALTER TABLE `t_possede_PDE`
  ADD PRIMARY KEY (`CCS_idConcours`,`CAT_idCategorie`),
  ADD KEY `fk_t_concours_ccs_has_t_categorie_cat_t_categorie_cat1_idx` (`CAT_idCategorie`),
  ADD KEY `fk_t_concours_ccs_has_t_categorie_cat_t_concours_ccs1_idx` (`CCS_idConcours`);

--
-- Index pour la table `t_siege_SGE`
--
ALTER TABLE `t_siege_SGE`
  ADD PRIMARY KEY (`CPT_idCompte`,`CCS_idConcours`),
  ADD KEY `fk_t_compte_jury_jry_has_t_concours_ccs_t_concours_ccs1_idx` (`CCS_idConcours`),
  ADD KEY `fk_t_compte_jury_jry_has_t_concours_ccs_t_compte_jury_jry1_idx` (`CPT_idCompte`);

--
-- Index pour la table `t_sujet_SJT`
--
ALTER TABLE `t_sujet_SJT`
  ADD PRIMARY KEY (`SJT_idSujet`),
  ADD KEY `fk_t_sujet_sjt_t_concours_ccs1_idx` (`CCS_idConcours`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `t_actualite_ACT`
--
ALTER TABLE `t_actualite_ACT`
  MODIFY `ACT_idActualite` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT pour la table `t_categorie_CAT`
--
ALTER TABLE `t_categorie_CAT`
  MODIFY `CAT_idCategorie` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `t_compte_CPT`
--
ALTER TABLE `t_compte_CPT`
  MODIFY `CPT_idCompte` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT pour la table `t_concours_CCS`
--
ALTER TABLE `t_concours_CCS`
  MODIFY `CCS_idConcours` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT pour la table `t_document_DCT`
--
ALTER TABLE `t_document_DCT`
  MODIFY `DCT_idDocument` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT pour la table `t_message_MSG`
--
ALTER TABLE `t_message_MSG`
  MODIFY `MSG_idMessage` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `t_participant_PTT`
--
ALTER TABLE `t_participant_PTT`
  MODIFY `PTT_idParticipant` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT pour la table `t_sujet_SJT`
--
ALTER TABLE `t_sujet_SJT`
  MODIFY `SJT_idSujet` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `t_actualite_ACT`
--
ALTER TABLE `t_actualite_ACT`
  ADD CONSTRAINT `fk_t_actualite_act_t_compte_organisateur_org1` FOREIGN KEY (`CPT_idCompte`) REFERENCES `t_compte_organisateur_ORG` (`CPT_idCompte`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_compte_jury_JRY`
--
ALTER TABLE `t_compte_jury_JRY`
  ADD CONSTRAINT `fk_t_compte_jury_jry_t_compte_cpt` FOREIGN KEY (`CPT_idCompte`) REFERENCES `t_compte_CPT` (`CPT_idCompte`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_compte_organisateur_ORG`
--
ALTER TABLE `t_compte_organisateur_ORG`
  ADD CONSTRAINT `fk_t_compte_organisateur_org_t_compte_cpt1` FOREIGN KEY (`CPT_idCompte`) REFERENCES `t_compte_CPT` (`CPT_idCompte`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_concours_CCS`
--
ALTER TABLE `t_concours_CCS`
  ADD CONSTRAINT `fk_t_concours_ccs_t_compte_organisateur_org1` FOREIGN KEY (`CPT_idCompte`) REFERENCES `t_compte_organisateur_ORG` (`CPT_idCompte`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_document_DCT`
--
ALTER TABLE `t_document_DCT`
  ADD CONSTRAINT `fk_t_document_dct_t_participant_ptt1` FOREIGN KEY (`PTT_idParticipant`) REFERENCES `t_participant_PTT` (`PTT_idParticipant`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_message_MSG`
--
ALTER TABLE `t_message_MSG`
  ADD CONSTRAINT `fk_t_message_msg_t_compte_jury_jry1` FOREIGN KEY (`CPT_idCompte`) REFERENCES `t_compte_jury_JRY` (`CPT_idCompte`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_message_msg_t_sujet_sjt1` FOREIGN KEY (`SJT_idSujet`) REFERENCES `t_sujet_SJT` (`SJT_idSujet`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_note_NTE`
--
ALTER TABLE `t_note_NTE`
  ADD CONSTRAINT `fk_t_compte_jury_jry_has_t_participant_ptt_t_compte_jury_jry1` FOREIGN KEY (`CPT_idCompte`) REFERENCES `t_compte_jury_JRY` (`CPT_idCompte`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_compte_jury_jry_has_t_participant_ptt_t_participant_ptt1` FOREIGN KEY (`PTT_idParticipant`) REFERENCES `t_participant_PTT` (`PTT_idParticipant`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_participant_PTT`
--
ALTER TABLE `t_participant_PTT`
  ADD CONSTRAINT `fk_t_participant_ptt_t_categorie_cat1` FOREIGN KEY (`CAT_idCategorie`) REFERENCES `t_categorie_CAT` (`CAT_idCategorie`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_participant_ptt_t_concours_ccs1` FOREIGN KEY (`CCS_idConcours`) REFERENCES `t_concours_CCS` (`CCS_idConcours`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_possede_PDE`
--
ALTER TABLE `t_possede_PDE`
  ADD CONSTRAINT `fk_t_concours_ccs_has_t_categorie_cat_t_categorie_cat1` FOREIGN KEY (`CAT_idCategorie`) REFERENCES `t_categorie_CAT` (`CAT_idCategorie`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_concours_ccs_has_t_categorie_cat_t_concours_ccs1` FOREIGN KEY (`CCS_idConcours`) REFERENCES `t_concours_CCS` (`CCS_idConcours`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_siege_SGE`
--
ALTER TABLE `t_siege_SGE`
  ADD CONSTRAINT `fk_t_compte_jury_jry_has_t_concours_ccs_t_compte_jury_jry1` FOREIGN KEY (`CPT_idCompte`) REFERENCES `t_compte_jury_JRY` (`CPT_idCompte`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_compte_jury_jry_has_t_concours_ccs_t_concours_ccs1` FOREIGN KEY (`CCS_idConcours`) REFERENCES `t_concours_CCS` (`CCS_idConcours`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_sujet_SJT`
--
ALTER TABLE `t_sujet_SJT`
  ADD CONSTRAINT `fk_t_sujet_sjt_t_concours_ccs1` FOREIGN KEY (`CCS_idConcours`) REFERENCES `t_concours_CCS` (`CCS_idConcours`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
