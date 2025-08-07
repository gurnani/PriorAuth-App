-- Description: Stored procedure to insert or update Prior Authorization data
-- 

CREATE PROCEDURE sp_UpsertPriorAuthorizationData
    @EpisodeId VARCHAR(50) = NULL,
    @EpisodeDate DATE = NULL,
	@InsCarrier VARCHAR(50) = NULL,
	@CPTCode VARCHAR(10) = NULL,
	@CompanyID int = NULL,
	@CaseNumber bigint = NULL,
    @AuthorizationStatus VARCHAR(50) = NULL,
    @RequestDate DATE = NULL,
    @ApprovalDate DATE = NULL,
    @DenialReason VARCHAR(500) = NULL,
    @AuthorizedUnits INT = NULL,
    @RequestedUnits INT = NULL,
    
    @PatientID VARCHAR(50),
    @PatientFirstName VARCHAR(100),
    @PatientLastName VARCHAR(100),
    @PatientDateOfBirth DATE,
    @PatientGender CHAR(1),
    @PatientLanguageCode VARCHAR(10) = NULL,
    @PatientAddressLine1 VARCHAR(200) = NULL,
    @PatientAddressLine2 VARCHAR(200) = NULL,
    @PatientCity VARCHAR(100) = NULL,
    @PatientState VARCHAR(50) = NULL,
    @PatientZipCode VARCHAR(20) = NULL,
    @PatientPhone VARCHAR(20) = NULL,
    @PatientEmailAddress VARCHAR(200) = NULL,
    @PatientMemberCode VARCHAR(50) = NULL,
    @PatientGroupNumber VARCHAR(50) = NULL,
    @PatientIPACode VARCHAR(50) = NULL,
    @PatientPlanCode VARCHAR(50) = NULL,
    
    @PhysicianID VARCHAR(50),
    @PhysicianFirstName VARCHAR(100),
    @PhysicianLastName VARCHAR(100),
    @PhysicianNPI VARCHAR(20),
    @PhysicianTIN VARCHAR(20),
    @PhysicianSpecialty1 VARCHAR(100) = NULL,
    @PhysicianSpecialty2 VARCHAR(100) = NULL,
    @PhysicianAddressLine1 VARCHAR(200) = NULL,
    @PhysicianAddressLine2 VARCHAR(200) = NULL,
    @PhysicianCity VARCHAR(100) = NULL,
    @PhysicianState VARCHAR(50) = NULL,
    @PhysicianZipCode VARCHAR(20) = NULL,
    @PhysicianPhone VARCHAR(20) = NULL,
    @PhysicianFax VARCHAR(20) = NULL,
    @PhysicianEmailAddress VARCHAR(200) = NULL,
    @PhysicianCellPhone VARCHAR(20) = NULL,
    
    @SiteID VARCHAR(50),
    @SiteName VARCHAR(200),
    @SiteNPI VARCHAR(20),
    @SiteTIN VARCHAR(20),
    @SiteSpecialty1 VARCHAR(100) = NULL,
    @SiteSpecialty2 VARCHAR(100) = NULL,
    @SiteAddressLine1 VARCHAR(200) = NULL,
    @SiteAddressLine2 VARCHAR(200) = NULL,
    @SiteCity VARCHAR(100) = NULL,
    @SiteState VARCHAR(50) = NULL,
    @SiteZipCode VARCHAR(20) = NULL,
    @SitePhone VARCHAR(20) = NULL,
    @SiteFax VARCHAR(20) = NULL,
    @SiteParticipating BIT = NULL,
    @SiteSteerageFlag VARCHAR(10) = NULL,
    
    @ProcedureCode VARCHAR(20),
    @ProcedureDescription VARCHAR(500) = NULL,
    @ProcedureQuantity INT = NULL,
    @ProcedureModifier VARCHAR(10) = NULL,
	@CPTModality VARCHAR(10) = NULL	
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @RecordExists BIT = 0;
    DECLARE @GeneratedEpisodeId VARCHAR(50);
    DECLARE @GeneratedEpisodeDate DATE;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF @EpisodeId IS NULL OR @EpisodeDate IS NULL
        BEGIN
            IF @EpisodeId IS NULL
            BEGIN
                SET @GeneratedEpisodeId = 'A' + FORMAT(DATEPART(YEAR, GETDATE()), '0000') + 
                                         FORMAT(DATEPART(DAYOFYEAR, GETDATE()), '000') + 
                                         FORMAT(ABS(CHECKSUM(NEWID())) % 10000, '0000');
            END
            ELSE
            BEGIN
                SET @GeneratedEpisodeId = @EpisodeId;
            END
            
            IF @EpisodeDate IS NULL
            BEGIN
                SET @GeneratedEpisodeDate = CAST(GETDATE() AS DATE);
            END
            ELSE
            BEGIN
                SET @GeneratedEpisodeDate = @EpisodeDate;
            END
            
            INSERT INTO tblAuthorization (
                EpisodeId, EpisodeDate, InsCarrier, CPTCode, CompanyID
            )
            VALUES (
                @GeneratedEpisodeId, @GeneratedEpisodeDate, @InsCarrier, @CPTCode, @CompanyID
            );
            
            SET @EpisodeId = @GeneratedEpisodeId;
            SET @EpisodeDate = @GeneratedEpisodeDate;
            SET @RecordExists = 0; -- This is a new record
        END
        ELSE
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM tblAuthorization 
                WHERE EpisodeId = @EpisodeId 
                AND EpisodeDate = @EpisodeDate
            )
            BEGIN
                SET @RecordExists = 1;
            END
        END
        
        IF @RecordExists = 1
        BEGIN
            UPDATE tblPatient 
            SET 
                PatientName = ISNULL(@PatientFirstName,'') + ISNULL(@PatientLastName,''),
                PatientDOB = @PatientDateOfBirth,
                PatientSex = @PatientGender,                
                PatientAddr1 = @PatientAddressLine1,
                PatientAddr2 = @PatientAddressLine2,
                PatientCity = @PatientCity,
                PatientState = @PatientState,
                PatientZip = @PatientZipCode,
                PatientPhone = @PatientPhone,                
                PatientMemberCode = @PatientMemberCode,
                GroupNumber = @PatientGroupNumber                
            WHERE PatientID = @PatientID
            AND EpisodeId = @EpisodeId 
            AND EpisodeDate = @EpisodeDate;
        END
        ELSE
        BEGIN
            INSERT INTO tblPatient (
                PatientID, EpisodeId, EpisodeDate, PatientName, PatientDOB,
                PatientSex, PatientAddr1, PatientAddr2, PatientCity, PatientState, 
                PatientZip, PatientPhone, PatientMemberCode, GroupNumber
            )
            VALUES (
                @PatientID, @EpisodeId, @EpisodeDate, ISNULL(@PatientFirstName,'') + ISNULL(@PatientLastName,''), 
                @PatientDateOfBirth, @PatientGender, @PatientAddressLine1, 
                @PatientAddressLine2, @PatientCity, @PatientState, @PatientZipCode, 
                @PatientPhone, @PatientMemberCode, @PatientGroupNumber
               
            );
        END
        
        IF @RecordExists = 1
        BEGIN
            UPDATE tblPhysician 
            SET 
                PhysName = ISNULL(@PhysicianFirstName,'') + ISNULL(@PhysicianLastName,''),
                NPI = @PhysicianNPI,
                PhysSpec1 = @PhysicianSpecialty1,
                PhysSpec2 = @PhysicianSpecialty2,
                PhysAddr1 = @PhysicianAddressLine1,
                PhysAddr2 = @PhysicianAddressLine2,
                PhysCity = @PhysicianCity,
                PhysState = @PhysicianState,
                PhysZip = @PhysicianZipCode,
                PhysPhone = @PhysicianPhone,
                PhysFax = @PhysicianFax,
                Email = @PhysicianEmailAddress,
                CellPhone = @PhysicianCellPhone
            WHERE OAOPhysID = @PhysicianID
            AND EpisodeId = @EpisodeId 
            AND EpisodeDate = @EpisodeDate;
        END
        ELSE
        BEGIN
            INSERT INTO tblPhysician (
                OAOPhysID, EpisodeId, EpisodeDate, PhysName, NPI, 
                PhysSpec1, PhysSpec2, PhysAddr1, PhysAddr2, PhysCity, PhysState, 
                PhysZip, PhysPhone, PhysFax, Email, CellPhone
            )
            VALUES (
                @PhysicianID, @EpisodeId, @EpisodeDate, ISNULL(@PhysicianFirstName,'') + ISNULL(@PhysicianLastName,''), 
                @PhysicianNPI, @PhysicianSpecialty1, @PhysicianSpecialty2, 
                @PhysicianAddressLine1, @PhysicianAddressLine2, @PhysicianCity, @PhysicianState, 
                @PhysicianZipCode, @PhysicianPhone, @PhysicianFax, @PhysicianEmailAddress, 
                @PhysicianCellPhone
            );
        END
        
        IF @RecordExists = 1
        BEGIN
            UPDATE tblSite 
            SET 
                SiteName = @SiteName,
                NPI = @SiteNPI,
                SiteSpec1 = @SiteSpecialty1,
                SiteSpec2 = @SiteSpecialty2,
                SiteAddr1 = @SiteAddressLine1,
                SiteAddr2 = @SiteAddressLine2,
                SiteCity = @SiteCity,
                SiteState = @SiteState,
                SiteZip = @SiteZipCode,
                SitePhone = @SitePhone,
                SiteFax = @SiteFax                
            WHERE OAOSiteID = @SiteID
            AND EpisodeId = @EpisodeId 
            AND EpisodeDate = @EpisodeDate;
        END
        ELSE
        BEGIN
            INSERT INTO tblSite (
                OAOSiteID, EpisodeId, EpisodeDate, SiteName, NPI, SiteSpec1, SiteSpec2, 
                SiteAddr1, SiteAddr2, SiteCity, SiteState, SiteZip, SitePhone, SiteFax
            )
            VALUES (
                @SiteID, @EpisodeId, @EpisodeDate, @SiteName, @SiteNPI, 
                @SiteSpecialty1, @SiteSpecialty2, @SiteAddressLine1, @SiteAddressLine2, 
                @SiteCity, @SiteState, @SiteZipCode, @SitePhone, @SiteFax
            );
        END
                        
        IF @RecordExists = 1
        BEGIN
            UPDATE tblAuthorization 
            SET 
                InsCarrier = @InsCarrier,
				CPTCode = @CPTCode,
				CompanyID = @CompanyID
            WHERE EpisodeId = @EpisodeId 
            AND EpisodeDate = @EpisodeDate;
        END
        ELSE IF @GeneratedEpisodeId IS NULL AND @GeneratedEpisodeDate IS NULL
        BEGIN
            INSERT INTO tblAuthorization (
                EpisodeId, EpisodeDate, InsCarrier,
				CPTCode, CompanyID
            )
            VALUES (
                @EpisodeId, @EpisodeDate, @InsCarrier, @CPTCode,
				@CompanyID
            );
        END
        
        COMMIT TRANSACTION;
        
        SELECT 
            'SUCCESS' AS Status,
            @EpisodeId AS EpisodeId,
            @EpisodeDate AS EpisodeDate,
            CASE WHEN @RecordExists = 1 THEN 'UPDATED' ELSE 'INSERTED' END AS Operation,
            'Prior authorization data processed successfully' AS Message;
            
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
        
        SELECT 
            'ERROR' AS Status,
            @EpisodeId AS EpisodeId,
            @EpisodeDate AS EpisodeDate,
            'FAILED' AS Operation,
            @ErrorMessage AS Message,
            @ErrorSeverity AS ErrorSeverity,
            @ErrorState AS ErrorState;
            
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
