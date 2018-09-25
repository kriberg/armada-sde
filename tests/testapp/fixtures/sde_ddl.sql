create schema evesde;

create table evesde."agtAgentTypes"
(
	"agentTypeID" integer not null
		constraint "agtAgentTypes_pkey"
			primary key,
	"agentType" varchar(50)
)
;

alter table evesde."agtAgentTypes" owner to yaml
;

create table evesde."agtAgents"
(
	"agentID" integer not null
		constraint "agtAgents_pkey"
			primary key,
	"divisionID" integer,
	"corporationID" integer,
	"locationID" integer,
	level integer,
	quality integer,
	"agentTypeID" integer,
	"isLocator" boolean
)
;

alter table evesde."agtAgents" owner to yaml
;

create index "ix_evesde_agtAgents_corporationID"
	on evesde."agtAgents" ("corporationID")
;

create index "ix_evesde_agtAgents_locationID"
	on evesde."agtAgents" ("locationID")
;

create table evesde."agtResearchAgents"
(
	"agentID" integer not null,
	"typeID" integer not null,
	constraint "agtResearchAgents_pkey"
		primary key ("agentID", "typeID")
)
;

alter table evesde."agtResearchAgents" owner to yaml
;

create index "ix_evesde_agtResearchAgents_typeID"
	on evesde."agtResearchAgents" ("typeID")
;

create table evesde."certCerts"
(
	"certID" integer not null
		constraint "certCerts_pkey"
			primary key,
	description text,
	"groupID" integer,
	name varchar(255)
)
;

alter table evesde."certCerts" owner to yaml
;

create table evesde."certMasteries"
(
	"typeID" integer,
	"masteryLevel" integer,
	"certID" integer
)
;

alter table evesde."certMasteries" owner to yaml
;

create table evesde."certSkills"
(
	"certID" integer,
	"skillID" integer,
	"certLevelInt" integer,
	"skillLevel" integer,
	"certLevelText" varchar(8)
)
;

alter table evesde."certSkills" owner to yaml
;

create index "ix_evesde_certSkills_skillID"
	on evesde."certSkills" ("skillID")
;

create table evesde."chrAncestries"
(
	"ancestryID" integer not null
		constraint "chrAncestries_pkey"
			primary key,
	"ancestryName" varchar(100),
	"bloodlineID" integer,
	description varchar(1000),
	perception integer,
	willpower integer,
	charisma integer,
	memory integer,
	intelligence integer,
	"iconID" integer,
	"shortDescription" varchar(500)
)
;

alter table evesde."chrAncestries" owner to yaml
;

create table evesde."chrAttributes"
(
	"attributeID" integer not null
		constraint "chrAttributes_pkey"
			primary key,
	"attributeName" varchar(100),
	description varchar(1000),
	"iconID" integer,
	"shortDescription" varchar(500),
	notes varchar(500)
)
;

alter table evesde."chrAttributes" owner to yaml
;

create table evesde."chrBloodlines"
(
	"bloodlineID" integer not null
		constraint "chrBloodlines_pkey"
			primary key,
	"bloodlineName" varchar(100),
	"raceID" integer,
	description varchar(1000),
	"maleDescription" varchar(1000),
	"femaleDescription" varchar(1000),
	"shipTypeID" integer,
	"corporationID" integer,
	perception integer,
	willpower integer,
	charisma integer,
	memory integer,
	intelligence integer,
	"iconID" integer,
	"shortDescription" varchar(500),
	"shortMaleDescription" varchar(500),
	"shortFemaleDescription" varchar(500)
)
;

alter table evesde."chrBloodlines" owner to yaml
;

create table evesde."chrFactions"
(
	"factionID" integer not null
		constraint "chrFactions_pkey"
			primary key,
	"factionName" varchar(100),
	description varchar(1000),
	"raceIDs" integer,
	"solarSystemID" integer,
	"corporationID" integer,
	"sizeFactor" double precision,
	"stationCount" integer,
	"stationSystemCount" integer,
	"militiaCorporationID" integer,
	"iconID" integer
)
;

alter table evesde."chrFactions" owner to yaml
;

create table evesde."chrRaces"
(
	"raceID" integer not null
		constraint "chrRaces_pkey"
			primary key,
	"raceName" varchar(100),
	description varchar(1000),
	"iconID" integer,
	"shortDescription" varchar(500)
)
;

alter table evesde."chrRaces" owner to yaml
;

create table evesde."crpActivities"
(
	"activityID" integer not null
		constraint "crpActivities_pkey"
			primary key,
	"activityName" varchar(100),
	description varchar(1000)
)
;

alter table evesde."crpActivities" owner to yaml
;

create table evesde."crpNPCCorporationDivisions"
(
	"corporationID" integer not null,
	"divisionID" integer not null,
	size integer,
	constraint "crpNPCCorporationDivisions_pkey"
		primary key ("corporationID", "divisionID")
)
;

alter table evesde."crpNPCCorporationDivisions" owner to yaml
;

create table evesde."crpNPCCorporationResearchFields"
(
	"skillID" integer not null,
	"corporationID" integer not null,
	constraint "crpNPCCorporationResearchFields_pkey"
		primary key ("skillID", "corporationID")
)
;

alter table evesde."crpNPCCorporationResearchFields" owner to yaml
;

create table evesde."crpNPCCorporationTrades"
(
	"corporationID" integer not null,
	"typeID" integer not null,
	constraint "crpNPCCorporationTrades_pkey"
		primary key ("corporationID", "typeID")
)
;

alter table evesde."crpNPCCorporationTrades" owner to yaml
;

create table evesde."crpNPCCorporations"
(
	"corporationID" integer not null
		constraint "crpNPCCorporations_pkey"
			primary key,
	size char,
	extent char,
	"solarSystemID" integer,
	"investorID1" integer,
	"investorShares1" integer,
	"investorID2" integer,
	"investorShares2" integer,
	"investorID3" integer,
	"investorShares3" integer,
	"investorID4" integer,
	"investorShares4" integer,
	"friendID" integer,
	"enemyID" integer,
	"publicShares" integer,
	"initialPrice" integer,
	"minSecurity" double precision,
	scattered boolean,
	fringe integer,
	corridor integer,
	hub integer,
	border integer,
	"factionID" integer,
	"sizeFactor" double precision,
	"stationCount" integer,
	"stationSystemCount" integer,
	description varchar(4000),
	"iconID" integer
)
;

alter table evesde."crpNPCCorporations" owner to yaml
;

create table evesde."crpNPCDivisions"
(
	"divisionID" integer not null
		constraint "crpNPCDivisions_pkey"
			primary key,
	"divisionName" varchar(100),
	description varchar(1000),
	"leaderType" varchar(100)
)
;

alter table evesde."crpNPCDivisions" owner to yaml
;

create table evesde."dgmAttributeCategories"
(
	"categoryID" integer not null
		constraint "dgmAttributeCategories_pkey"
			primary key,
	"categoryName" varchar(50),
	"categoryDescription" varchar(200)
)
;

alter table evesde."dgmAttributeCategories" owner to yaml
;

create table evesde."dgmAttributeTypes"
(
	"attributeID" integer not null
		constraint "dgmAttributeTypes_pkey"
			primary key,
	"attributeName" varchar(100),
	description varchar(1000),
	"iconID" integer,
	"defaultValue" double precision,
	published boolean,
	"displayName" varchar(150),
	"unitID" integer,
	stackable boolean,
	"highIsGood" boolean,
	"categoryID" integer
)
;

alter table evesde."dgmAttributeTypes" owner to yaml
;

create table evesde."dgmEffects"
(
	"effectID" integer not null
		constraint "dgmEffects_pkey"
			primary key,
	"effectName" varchar(400),
	"effectCategory" integer,
	"preExpression" integer,
	"postExpression" integer,
	description varchar(1000),
	guid varchar(60),
	"iconID" integer,
	"isOffensive" boolean,
	"isAssistance" boolean,
	"durationAttributeID" integer,
	"trackingSpeedAttributeID" integer,
	"dischargeAttributeID" integer,
	"rangeAttributeID" integer,
	"falloffAttributeID" integer,
	"disallowAutoRepeat" boolean,
	published boolean,
	"displayName" varchar(100),
	"isWarpSafe" boolean,
	"rangeChance" boolean,
	"electronicChance" boolean,
	"propulsionChance" boolean,
	distribution integer,
	"sfxName" varchar(20),
	"npcUsageChanceAttributeID" integer,
	"npcActivationChanceAttributeID" integer,
	"fittingUsageChanceAttributeID" integer,
	"modifierInfo" text
)
;

alter table evesde."dgmEffects" owner to yaml
;

create table evesde."dgmExpressions"
(
	"expressionID" integer not null
		constraint "dgmExpressions_pkey"
			primary key,
	"operandID" integer,
	arg1 integer,
	arg2 integer,
	"expressionValue" varchar(100),
	description varchar(1000),
	"expressionName" varchar(500),
	"expressionTypeID" integer,
	"expressionGroupID" integer,
	"expressionAttributeID" integer
)
;

alter table evesde."dgmExpressions" owner to yaml
;

create table evesde."dgmTypeAttributes"
(
	"typeID" integer not null,
	"attributeID" integer not null,
	"valueInt" integer,
	"valueFloat" double precision,
	constraint "dgmTypeAttributes_pkey"
		primary key ("typeID", "attributeID")
)
;

alter table evesde."dgmTypeAttributes" owner to yaml
;

create index "ix_evesde_dgmTypeAttributes_attributeID"
	on evesde."dgmTypeAttributes" ("attributeID")
;

create table evesde."dgmTypeEffects"
(
	"typeID" integer not null,
	"effectID" integer not null,
	"isDefault" boolean,
	constraint "dgmTypeEffects_pkey"
		primary key ("typeID", "effectID")
)
;

alter table evesde."dgmTypeEffects" owner to yaml
;

create table evesde."eveGraphics"
(
	"graphicID" integer not null
		constraint "eveGraphics_pkey"
			primary key,
	"sofFactionName" varchar(100),
	"graphicFile" varchar(100),
	"sofHullName" varchar(100),
	"sofRaceName" varchar(100),
	description text
)
;

alter table evesde."eveGraphics" owner to yaml
;

create table evesde."eveIcons"
(
	"iconID" integer not null
		constraint "eveIcons_pkey"
			primary key,
	"iconFile" varchar(500),
	description text
)
;

alter table evesde."eveIcons" owner to yaml
;

create table evesde."eveUnits"
(
	"unitID" integer not null
		constraint "eveUnits_pkey"
			primary key,
	"unitName" varchar(100),
	"displayName" varchar(50),
	description varchar(1000)
)
;

alter table evesde."eveUnits" owner to yaml
;

create table evesde."industryActivity"
(
	"typeID" integer not null,
	"activityID" integer not null,
	time integer,
	constraint "industryActivity_pkey"
		primary key ("typeID", "activityID")
)
;

alter table evesde."industryActivity" owner to yaml
;

create index "ix_evesde_industryActivity_activityID"
	on evesde."industryActivity" ("activityID")
;

create table evesde."industryActivityMaterials"
(
	"typeID" integer,
	"activityID" integer,
	"materialTypeID" integer,
	quantity integer
)
;

alter table evesde."industryActivityMaterials" owner to yaml
;

create index "industryActivityMaterials_idx1"
	on evesde."industryActivityMaterials" ("typeID", "activityID")
;

create index "ix_evesde_industryActivityMaterials_typeID"
	on evesde."industryActivityMaterials" ("typeID")
;

create table evesde."industryActivityProbabilities"
(
	"typeID" integer,
	"activityID" integer,
	"productTypeID" integer,
	probability numeric(3,2)
)
;

alter table evesde."industryActivityProbabilities" owner to yaml
;

create index "ix_evesde_industryActivityProbabilities_productTypeID"
	on evesde."industryActivityProbabilities" ("productTypeID")
;

create index "ix_evesde_industryActivityProbabilities_typeID"
	on evesde."industryActivityProbabilities" ("typeID")
;

create table evesde."industryActivityProducts"
(
	"typeID" integer,
	"activityID" integer,
	"productTypeID" integer,
	quantity integer
)
;

alter table evesde."industryActivityProducts" owner to yaml
;

create index "ix_evesde_industryActivityProducts_productTypeID"
	on evesde."industryActivityProducts" ("productTypeID")
;

create index "ix_evesde_industryActivityProducts_typeID"
	on evesde."industryActivityProducts" ("typeID")
;

create table evesde."industryActivityRaces"
(
	"typeID" integer,
	"activityID" integer,
	"productTypeID" integer,
	"raceID" integer
)
;

alter table evesde."industryActivityRaces" owner to yaml
;

create index "ix_evesde_industryActivityRaces_productTypeID"
	on evesde."industryActivityRaces" ("productTypeID")
;

create index "ix_evesde_industryActivityRaces_typeID"
	on evesde."industryActivityRaces" ("typeID")
;

create table evesde."industryActivitySkills"
(
	"typeID" integer,
	"activityID" integer,
	"skillID" integer,
	level integer
)
;

alter table evesde."industryActivitySkills" owner to yaml
;

create index "industryActivitySkills_idx1"
	on evesde."industryActivitySkills" ("typeID", "activityID")
;

create index "ix_evesde_industryActivitySkills_skillID"
	on evesde."industryActivitySkills" ("skillID")
;

create index "ix_evesde_industryActivitySkills_typeID"
	on evesde."industryActivitySkills" ("typeID")
;

create table evesde."industryBlueprints"
(
	"typeID" integer not null
		constraint "industryBlueprints_pkey"
			primary key,
	"maxProductionLimit" integer
)
;

alter table evesde."industryBlueprints" owner to yaml
;

create table evesde."invCategories"
(
	"categoryID" integer not null
		constraint "invCategories_pkey"
			primary key,
	"categoryName" varchar(100),
	"iconID" integer,
	published boolean
)
;

alter table evesde."invCategories" owner to yaml
;

create table evesde."invContrabandTypes"
(
	"factionID" integer not null,
	"typeID" integer not null,
	"standingLoss" double precision,
	"confiscateMinSec" double precision,
	"fineByValue" double precision,
	"attackMinSec" double precision,
	constraint "invContrabandTypes_pkey"
		primary key ("factionID", "typeID")
)
;

alter table evesde."invContrabandTypes" owner to yaml
;

create index "ix_evesde_invContrabandTypes_typeID"
	on evesde."invContrabandTypes" ("typeID")
;

create table evesde."invControlTowerResourcePurposes"
(
	purpose integer not null
		constraint "invControlTowerResourcePurposes_pkey"
			primary key,
	"purposeText" varchar(100)
)
;

alter table evesde."invControlTowerResourcePurposes" owner to yaml
;

create table evesde."invControlTowerResources"
(
	"controlTowerTypeID" integer not null,
	"resourceTypeID" integer not null,
	purpose integer,
	quantity integer,
	"minSecurityLevel" double precision,
	"factionID" integer,
	constraint "invControlTowerResources_pkey"
		primary key ("controlTowerTypeID", "resourceTypeID")
)
;

alter table evesde."invControlTowerResources" owner to yaml
;

create table evesde."invFlags"
(
	"flagID" integer not null
		constraint "invFlags_pkey"
			primary key,
	"flagName" varchar(200),
	"flagText" varchar(100),
	"orderID" integer
)
;

alter table evesde."invFlags" owner to yaml
;

create table evesde."invGroups"
(
	"groupID" integer not null
		constraint "invGroups_pkey"
			primary key,
	"categoryID" integer,
	"groupName" varchar(100),
	"iconID" integer,
	"useBasePrice" boolean,
	anchored boolean,
	anchorable boolean,
	"fittableNonSingleton" boolean,
	published boolean
)
;

alter table evesde."invGroups" owner to yaml
;

create index "ix_evesde_invGroups_categoryID"
	on evesde."invGroups" ("categoryID")
;

create table evesde."invItems"
(
	"itemID" integer not null
		constraint "invItems_pkey"
			primary key,
	"typeID" integer not null,
	"ownerID" integer not null,
	"locationID" integer not null,
	"flagID" integer not null,
	quantity integer not null
)
;

alter table evesde."invItems" owner to yaml
;

create index "items_IX_OwnerLocation"
	on evesde."invItems" ("ownerID", "locationID")
;

create index "ix_evesde_invItems_locationID"
	on evesde."invItems" ("locationID")
;

create table evesde."invMarketGroups"
(
	"marketGroupID" integer not null
		constraint "invMarketGroups_pkey"
			primary key,
	"parentGroupID" integer,
	"marketGroupName" varchar(100),
	description varchar(3000),
	"iconID" integer,
	"hasTypes" boolean
)
;

alter table evesde."invMarketGroups" owner to yaml
;

create table evesde."invMetaGroups"
(
	"metaGroupID" integer not null
		constraint "invMetaGroups_pkey"
			primary key,
	"metaGroupName" varchar(100),
	description varchar(1000),
	"iconID" integer
)
;

alter table evesde."invMetaGroups" owner to yaml
;

create table evesde."invMetaTypes"
(
	"typeID" integer not null
		constraint "invMetaTypes_pkey"
			primary key,
	"parentTypeID" integer,
	"metaGroupID" integer
)
;

alter table evesde."invMetaTypes" owner to yaml
;

create table evesde."invNames"
(
	"itemID" integer not null
		constraint "invNames_pkey"
			primary key,
	"itemName" varchar(200) not null
)
;

alter table evesde."invNames" owner to yaml
;

create table evesde."invPositions"
(
	"itemID" integer not null
		constraint "invPositions_pkey"
			primary key,
	x double precision not null,
	y double precision not null,
	z double precision not null,
	yaw real,
	pitch real,
	roll real
)
;

alter table evesde."invPositions" owner to yaml
;

create table evesde."invTraits"
(
	"traitID" serial not null
		constraint "invTraits_pkey"
			primary key,
	"typeID" integer,
	"skillID" integer,
	bonus double precision,
	"bonusText" text,
	"unitID" integer
)
;

alter table evesde."invTraits" owner to yaml
;

create table evesde."invTypeMaterials"
(
	"typeID" integer not null,
	"materialTypeID" integer not null,
	quantity integer not null,
	constraint "invTypeMaterials_pkey"
		primary key ("typeID", "materialTypeID")
)
;

alter table evesde."invTypeMaterials" owner to yaml
;

create table evesde."invTypeReactions"
(
	"reactionTypeID" integer not null,
	input boolean not null,
	"typeID" integer not null,
	quantity integer,
	constraint "invTypeReactions_pkey"
		primary key ("reactionTypeID", input, "typeID")
)
;

alter table evesde."invTypeReactions" owner to yaml
;

create table evesde."invTypes"
(
	"typeID" integer not null
		constraint "invTypes_pkey"
			primary key,
	"groupID" integer,
	"typeName" varchar(100),
	description text,
	mass double precision,
	volume double precision,
	capacity double precision,
	"portionSize" integer,
	"raceID" integer,
	"basePrice" numeric(19,4),
	published boolean,
	"marketGroupID" integer,
	"iconID" integer,
	"soundID" integer,
	"graphicID" integer
)
;

alter table evesde."invTypes" owner to yaml
;

create index "ix_evesde_invTypes_groupID"
	on evesde."invTypes" ("groupID")
;

create table evesde."invUniqueNames"
(
	"itemID" integer not null
		constraint "invUniqueNames_pkey"
			primary key,
	"itemName" varchar(200) not null,
	"groupID" integer
)
;

alter table evesde."invUniqueNames" owner to yaml
;

create index "invUniqueNames_IX_GroupName"
	on evesde."invUniqueNames" ("groupID", "itemName")
;

create unique index "ix_evesde_invUniqueNames_itemName"
	on evesde."invUniqueNames" ("itemName")
;

create table evesde."invVolumes"
(
	"typeID" integer not null
		constraint "invVolumes_pkey"
			primary key,
	volume integer
)
;

alter table evesde."invVolumes" owner to yaml
;

create table evesde."mapCelestialStatistics"
(
	"celestialID" integer not null
		constraint "mapCelestialStatistics_pkey"
			primary key,
	temperature double precision,
	"spectralClass" varchar(10),
	luminosity double precision,
	age double precision,
	life double precision,
	"orbitRadius" double precision,
	eccentricity double precision,
	"massDust" double precision,
	"massGas" double precision,
	fragmented boolean,
	density double precision,
	"surfaceGravity" double precision,
	"escapeVelocity" double precision,
	"orbitPeriod" double precision,
	"rotationRate" double precision,
	locked boolean,
	pressure double precision,
	radius double precision,
	mass integer
)
;

alter table evesde."mapCelestialStatistics" owner to yaml
;

create table evesde."mapConstellationJumps"
(
	"fromRegionID" integer,
	"fromConstellationID" integer not null,
	"toConstellationID" integer not null,
	"toRegionID" integer,
	constraint "mapConstellationJumps_pkey"
		primary key ("fromConstellationID", "toConstellationID")
)
;

alter table evesde."mapConstellationJumps" owner to yaml
;

create table evesde."mapConstellations"
(
	"regionID" integer,
	"constellationID" integer not null
		constraint "mapConstellations_pkey"
			primary key,
	"constellationName" varchar(100),
	x double precision,
	y double precision,
	z double precision,
	"xMin" double precision,
	"xMax" double precision,
	"yMin" double precision,
	"yMax" double precision,
	"zMin" double precision,
	"zMax" double precision,
	"factionID" integer,
	radius double precision
)
;

alter table evesde."mapConstellations" owner to yaml
;

create table evesde."mapDenormalize"
(
	"itemID" integer not null
		constraint "mapDenormalize_pkey"
			primary key,
	"typeID" integer,
	"groupID" integer,
	"solarSystemID" integer,
	"constellationID" integer,
	"regionID" integer,
	"orbitID" integer,
	x double precision,
	y double precision,
	z double precision,
	radius double precision,
	"itemName" varchar(100),
	security double precision,
	"celestialIndex" integer,
	"orbitIndex" integer
)
;

alter table evesde."mapDenormalize" owner to yaml
;

create index "ix_evesde_mapDenormalize_constellationID"
	on evesde."mapDenormalize" ("constellationID")
;

create index "ix_evesde_mapDenormalize_orbitID"
	on evesde."mapDenormalize" ("orbitID")
;

create index "ix_evesde_mapDenormalize_regionID"
	on evesde."mapDenormalize" ("regionID")
;

create index "ix_evesde_mapDenormalize_solarSystemID"
	on evesde."mapDenormalize" ("solarSystemID")
;

create index "ix_evesde_mapDenormalize_typeID"
	on evesde."mapDenormalize" ("typeID")
;

create index "mapDenormalize_IX_groupConstellation"
	on evesde."mapDenormalize" ("groupID", "constellationID")
;

create index "mapDenormalize_IX_groupRegion"
	on evesde."mapDenormalize" ("groupID", "regionID")
;

create index "mapDenormalize_IX_groupSystem"
	on evesde."mapDenormalize" ("groupID", "solarSystemID")
;

create table evesde."mapJumps"
(
	"stargateID" integer not null
		constraint "mapJumps_pkey"
			primary key,
	"destinationID" integer
)
;

alter table evesde."mapJumps" owner to yaml
;

create table evesde."mapLandmarks"
(
	"landmarkID" integer not null
		constraint "mapLandmarks_pkey"
			primary key,
	"landmarkName" varchar(100),
	description text,
	"locationID" integer,
	x double precision,
	y double precision,
	z double precision,
	"iconID" integer
)
;

alter table evesde."mapLandmarks" owner to yaml
;

create table evesde."mapLocationScenes"
(
	"locationID" integer not null
		constraint "mapLocationScenes_pkey"
			primary key,
	"graphicID" integer
)
;

alter table evesde."mapLocationScenes" owner to yaml
;

create table evesde."mapLocationWormholeClasses"
(
	"locationID" integer not null
		constraint "mapLocationWormholeClasses_pkey"
			primary key,
	"wormholeClassID" integer
)
;

alter table evesde."mapLocationWormholeClasses" owner to yaml
;

create table evesde."mapRegionJumps"
(
	"fromRegionID" integer not null,
	"toRegionID" integer not null,
	constraint "mapRegionJumps_pkey"
		primary key ("fromRegionID", "toRegionID")
)
;

alter table evesde."mapRegionJumps" owner to yaml
;

create table evesde."mapRegions"
(
	"regionID" integer not null
		constraint "mapRegions_pkey"
			primary key,
	"regionName" varchar(100),
	x double precision,
	y double precision,
	z double precision,
	"xMin" double precision,
	"xMax" double precision,
	"yMin" double precision,
	"yMax" double precision,
	"zMin" double precision,
	"zMax" double precision,
	"factionID" integer,
	radius double precision
)
;

alter table evesde."mapRegions" owner to yaml
;

create table evesde."mapSolarSystemJumps"
(
	"fromRegionID" integer,
	"fromConstellationID" integer,
	"fromSolarSystemID" integer not null,
	"toSolarSystemID" integer not null,
	"toConstellationID" integer,
	"toRegionID" integer,
	constraint "mapSolarSystemJumps_pkey"
		primary key ("fromSolarSystemID", "toSolarSystemID")
)
;

alter table evesde."mapSolarSystemJumps" owner to yaml
;

create table evesde."mapSolarSystems"
(
	"regionID" integer,
	"constellationID" integer,
	"solarSystemID" integer not null
		constraint "mapSolarSystems_pkey"
			primary key,
	"solarSystemName" varchar(100),
	x double precision,
	y double precision,
	z double precision,
	"xMin" double precision,
	"xMax" double precision,
	"yMin" double precision,
	"yMax" double precision,
	"zMin" double precision,
	"zMax" double precision,
	luminosity double precision,
	border boolean,
	fringe boolean,
	corridor boolean,
	hub boolean,
	international boolean,
	regional boolean,
	constellation boolean,
	security double precision,
	"factionID" integer,
	radius double precision,
	"sunTypeID" integer,
	"securityClass" varchar(2)
)
;

alter table evesde."mapSolarSystems" owner to yaml
;

create index "ix_evesde_mapSolarSystems_constellationID"
	on evesde."mapSolarSystems" ("constellationID")
;

create index "ix_evesde_mapSolarSystems_regionID"
	on evesde."mapSolarSystems" ("regionID")
;

create index "ix_evesde_mapSolarSystems_security"
	on evesde."mapSolarSystems" (security)
;

create table evesde."mapUniverse"
(
	"universeID" integer not null
		constraint "mapUniverse_pkey"
			primary key,
	"universeName" varchar(100),
	x double precision,
	y double precision,
	z double precision,
	"xMin" double precision,
	"xMax" double precision,
	"yMin" double precision,
	"yMax" double precision,
	"zMin" double precision,
	"zMax" double precision,
	radius double precision
)
;

alter table evesde."mapUniverse" owner to yaml
;

create table evesde."planetSchematics"
(
	"schematicID" integer not null
		constraint "planetSchematics_pkey"
			primary key,
	"schematicName" varchar(255),
	"cycleTime" integer
)
;

alter table evesde."planetSchematics" owner to yaml
;

create table evesde."planetSchematicsPinMap"
(
	"schematicID" integer not null,
	"pinTypeID" integer not null,
	constraint "planetSchematicsPinMap_pkey"
		primary key ("schematicID", "pinTypeID")
)
;

alter table evesde."planetSchematicsPinMap" owner to yaml
;

create table evesde."planetSchematicsTypeMap"
(
	"schematicID" integer not null,
	"typeID" integer not null,
	quantity integer,
	"isInput" boolean,
	constraint "planetSchematicsTypeMap_pkey"
		primary key ("schematicID", "typeID")
)
;

alter table evesde."planetSchematicsTypeMap" owner to yaml
;

create table evesde."ramActivities"
(
	"activityID" integer not null
		constraint "ramActivities_pkey"
			primary key,
	"activityName" varchar(100),
	"iconNo" varchar(5),
	description varchar(1000),
	published boolean
)
;

alter table evesde."ramActivities" owner to yaml
;

create table evesde."ramAssemblyLineStations"
(
	"stationID" integer not null,
	"assemblyLineTypeID" integer not null,
	quantity integer,
	"stationTypeID" integer,
	"ownerID" integer,
	"solarSystemID" integer,
	"regionID" integer,
	constraint "ramAssemblyLineStations_pkey"
		primary key ("stationID", "assemblyLineTypeID")
)
;

alter table evesde."ramAssemblyLineStations" owner to yaml
;

create index "ix_evesde_ramAssemblyLineStations_ownerID"
	on evesde."ramAssemblyLineStations" ("ownerID")
;

create index "ix_evesde_ramAssemblyLineStations_regionID"
	on evesde."ramAssemblyLineStations" ("regionID")
;

create index "ix_evesde_ramAssemblyLineStations_solarSystemID"
	on evesde."ramAssemblyLineStations" ("solarSystemID")
;

create table evesde."ramAssemblyLineTypeDetailPerCategory"
(
	"assemblyLineTypeID" integer not null,
	"categoryID" integer not null,
	"timeMultiplier" double precision,
	"materialMultiplier" double precision,
	"costMultiplier" double precision,
	constraint "ramAssemblyLineTypeDetailPerCategory_pkey"
		primary key ("assemblyLineTypeID", "categoryID")
)
;

alter table evesde."ramAssemblyLineTypeDetailPerCategory" owner to yaml
;

create table evesde."ramAssemblyLineTypeDetailPerGroup"
(
	"assemblyLineTypeID" integer not null,
	"groupID" integer not null,
	"timeMultiplier" double precision,
	"materialMultiplier" double precision,
	"costMultiplier" double precision,
	constraint "ramAssemblyLineTypeDetailPerGroup_pkey"
		primary key ("assemblyLineTypeID", "groupID")
)
;

alter table evesde."ramAssemblyLineTypeDetailPerGroup" owner to yaml
;

create table evesde."ramAssemblyLineTypes"
(
	"assemblyLineTypeID" integer not null
		constraint "ramAssemblyLineTypes_pkey"
			primary key,
	"assemblyLineTypeName" varchar(100),
	description varchar(1000),
	"baseTimeMultiplier" double precision,
	"baseMaterialMultiplier" double precision,
	"baseCostMultiplier" double precision,
	volume double precision,
	"activityID" integer,
	"minCostPerHour" double precision
)
;

alter table evesde."ramAssemblyLineTypes" owner to yaml
;

create table evesde."ramInstallationTypeContents"
(
	"installationTypeID" integer not null,
	"assemblyLineTypeID" integer not null,
	quantity integer,
	constraint "ramInstallationTypeContents_pkey"
		primary key ("installationTypeID", "assemblyLineTypeID")
)
;

alter table evesde."ramInstallationTypeContents" owner to yaml
;

create table evesde."skinLicense"
(
	"licenseTypeID" integer not null
		constraint "skinLicense_pkey"
			primary key,
	duration integer,
	"skinID" integer
)
;

alter table evesde."skinLicense" owner to yaml
;

create table evesde."skinMaterials"
(
	"skinMaterialID" integer not null
		constraint "skinMaterials_pkey"
			primary key,
	"displayNameID" integer,
	"materialSetID" integer
)
;

alter table evesde."skinMaterials" owner to yaml
;

create table evesde."skinShip"
(
	"skinID" integer,
	"typeID" integer
)
;

alter table evesde."skinShip" owner to yaml
;

create index "ix_evesde_skinShip_skinID"
	on evesde."skinShip" ("skinID")
;

create index "ix_evesde_skinShip_typeID"
	on evesde."skinShip" ("typeID")
;

create table evesde.skins
(
	"skinID" integer not null
		constraint skins_pkey
			primary key,
	"internalName" varchar(70),
	"skinMaterialID" integer
)
;

alter table evesde.skins owner to yaml
;

create table evesde."staOperationServices"
(
	"operationID" integer not null,
	"serviceID" integer not null,
	constraint "staOperationServices_pkey"
		primary key ("operationID", "serviceID")
)
;

alter table evesde."staOperationServices" owner to yaml
;

create table evesde."staOperations"
(
	"activityID" integer,
	"operationID" integer not null
		constraint "staOperations_pkey"
			primary key,
	"operationName" varchar(100),
	description varchar(1000),
	fringe integer,
	corridor integer,
	hub integer,
	border integer,
	ratio integer,
	"caldariStationTypeID" integer,
	"minmatarStationTypeID" integer,
	"amarrStationTypeID" integer,
	"gallenteStationTypeID" integer,
	"joveStationTypeID" integer
)
;

alter table evesde."staOperations" owner to yaml
;

create table evesde."staServices"
(
	"serviceID" integer not null
		constraint "staServices_pkey"
			primary key,
	"serviceName" varchar(100),
	description varchar(1000)
)
;

alter table evesde."staServices" owner to yaml
;

create table evesde."staStationTypes"
(
	"stationTypeID" integer not null
		constraint "staStationTypes_pkey"
			primary key,
	"dockEntryX" double precision,
	"dockEntryY" double precision,
	"dockEntryZ" double precision,
	"dockOrientationX" double precision,
	"dockOrientationY" double precision,
	"dockOrientationZ" double precision,
	"operationID" integer,
	"officeSlots" integer,
	"reprocessingEfficiency" double precision,
	conquerable boolean
)
;

alter table evesde."staStationTypes" owner to yaml
;

create table evesde."staStations"
(
	"stationID" bigint not null
		constraint "staStations_pkey"
			primary key,
	security double precision,
	"dockingCostPerVolume" double precision,
	"maxShipVolumeDockable" double precision,
	"officeRentalCost" integer,
	"operationID" integer,
	"stationTypeID" integer,
	"corporationID" integer,
	"solarSystemID" integer,
	"constellationID" integer,
	"regionID" integer,
	"stationName" varchar(100),
	x double precision,
	y double precision,
	z double precision,
	"reprocessingEfficiency" double precision,
	"reprocessingStationsTake" double precision,
	"reprocessingHangarFlag" integer
)
;

alter table evesde."staStations" owner to yaml
;

create index "ix_evesde_staStations_constellationID"
	on evesde."staStations" ("constellationID")
;

create index "ix_evesde_staStations_corporationID"
	on evesde."staStations" ("corporationID")
;

create index "ix_evesde_staStations_operationID"
	on evesde."staStations" ("operationID")
;

create index "ix_evesde_staStations_regionID"
	on evesde."staStations" ("regionID")
;

create index "ix_evesde_staStations_solarSystemID"
	on evesde."staStations" ("solarSystemID")
;

create index "ix_evesde_staStations_stationTypeID"
	on evesde."staStations" ("stationTypeID")
;

create table evesde."translationTables"
(
	"sourceTable" varchar(200) not null,
	"destinationTable" varchar(200),
	"translatedKey" varchar(200) not null,
	"tcGroupID" integer,
	"tcID" integer,
	constraint "translationTables_pkey"
		primary key ("sourceTable", "translatedKey")
)
;

alter table evesde."translationTables" owner to yaml
;

create table evesde."trnTranslationColumns"
(
	"tcGroupID" integer,
	"tcID" integer not null
		constraint "trnTranslationColumns_pkey"
			primary key,
	"tableName" varchar(256) not null,
	"columnName" varchar(128) not null,
	"masterID" varchar(128)
)
;

alter table evesde."trnTranslationColumns" owner to yaml
;

create table evesde."trnTranslationLanguages"
(
	"numericLanguageID" integer not null
		constraint "trnTranslationLanguages_pkey"
			primary key,
	"languageID" varchar(50),
	"languageName" varchar(200)
)
;

alter table evesde."trnTranslationLanguages" owner to yaml
;

create table evesde."trnTranslations"
(
	"tcID" integer not null,
	"keyID" integer not null,
	"languageID" varchar(50) not null,
	text text not null,
	constraint "trnTranslations_pkey"
		primary key ("tcID", "keyID", "languageID")
)
;

alter table evesde."trnTranslations" owner to yaml
;

create table evesde."warCombatZoneSystems"
(
	"solarSystemID" integer not null
		constraint "warCombatZoneSystems_pkey"
			primary key,
	"combatZoneID" integer
)
;

alter table evesde."warCombatZoneSystems" owner to yaml
;

create table evesde."warCombatZones"
(
	"combatZoneID" integer not null
		constraint "warCombatZones_pkey"
			primary key,
	"combatZoneName" varchar(100),
	"factionID" integer,
	"centerSystemID" integer,
	description varchar(500)
)
;

alter table evesde."warCombatZones" owner to yaml
;

