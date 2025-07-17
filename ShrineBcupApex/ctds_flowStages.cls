/**********************************************************************************************
 NAME: ctds_flowStages
 DESCRIPTION: This class is used for creating side navigation and flow object
 @AUTHOR:Nate Shilling
 @DATE: 10-October-2020

 MODIFICATION LOG:
 DEVELOPER                         DATE: 19-October-2020         DESCRIPTION
 _____________________________________________________________________________________________
 Nate Shilling                                                  Created the first version    
 Sushri Sarita Nayak                                            Added Logic for Sorting the List                                                                                                           updated framework logic
***********************************************************************************************/
global with sharing class ctds_flowStages {
      public static Map<String,String>  labelMaps = new Map<String,String>();
   /* Below invocable method is being called the main flows to be able to populate side nav list sorted by order*/
    @InvocableMethod
    public static List<Results> getSideNavigationSection(List<Requests> Requests) {
       getAppLabels();
       ctds_flowStage[] stages = new ctds_flowStage[]{};
       ctds_flowStage[] blankArray = new ctds_flowStage[]{};
       if(Requests.size() > 0){
       for(Section_Settings__mdt section : [SELECT MasterLabel,DeveloperName,Label__c,Flow_Type__c,Component_Name__c,Status__c,PageRef__c,Id,Section_Name__c,Lien_Type__c,Section_Order__c,Hide__c,ShowWhen__c,
                                               (Select MasterLabel,DeveloperName,Label__c,Type__c,SubSection_Component_Name__c,Status__c,PageRef__c,Id,SubSection_Name__c,SubSection_Order__c,Hide__c,ShowWhen__c from SubSection_Settings_mdts__r)
                                               FROM Section_Settings__mdt
                                               where Flow_Type__c =: Requests[0].flowName and Is_Active__c = true limit 10000
                                               ]){
           ctds_flowStage stage = new ctds_flowStage('','',true,1,'',false,'','',blankArray);
           ctds_flowStage[] lstSubSections = new ctds_flowStage[]{};
           
           //populating the stages
           stage.status = section.Status__c;
           if(labelMaps.get(section.Section_Name__c.trim())!=null){
            stage.label = labelMaps.get(section.Section_Name__c.trim()).trim();
           }else{
           stage.label = section.Section_Name__c;
           }
           stage.masterLabel = section.MasterLabel;
           stage.showWhen= section.ShowWhen__c;
           stage.show = section.Hide__c ? false: true;
           stage.order = integer.valueOf(section.Section_Order__c);
           stage.IsActive = false;
           stage.pageNameRef = section.DeveloperName;
           stage.lienType = section.Lien_Type__c;
           stage.flowName = section.Flow_Type__c;
          
           // populating the substages
           for(SubSection_Settings__mdt subSection : section.SubSection_Settings_mdts__r){    
            ctds_flowStage subStage = new ctds_flowStage('','',true,1,'',false,'','',blankArray);     
               subStage.status = subSection.Status__c;
               if(labelMaps.get(subSection.SubSection_Name__c.trim())!=null){
                  subStage.label = labelMaps.get(subSection.SubSection_Name__c.trim()).trim();
                 }else{
                 subStage.label = subSection.SubSection_Name__c;
                 }
               subStage.showWhen = subSection.ShowWhen__c;
               subStage.show = subSection.Hide__c ? false: true;
               subStage.lienType =  subSection.Type__c;
               subStage.order = integer.valueOf(subSection.SubSection_Order__c);
               subStage.IsActive = false;
               subStage.pageNameRef = subSection.DeveloperName; 
               substage.flowName = QnA_Constants.EMPTY_STRING;
               subStage.masterLabel = subSection.MasterLabel;
               lstSubSections.add(subStage); 
           }
           lstSubSections.sort();
           stage.subsections = lstSubSections; 
           stages.add(stage);
           stages.sort();
       }  
    }
       List<Results> lstResults = new List<Results>();
       Results r = new Results();
        r.records = Json.serialize(stages);
        lstResults.add(r);
        return lstResults;
    }

    global without sharing class Requests {
       @InvocableVariable
       global string flowName;
   }    
    global without sharing class Results {
       @InvocableVariable
       global string records;
   }
   public static Map<String,String> getAppLabels(){
      labelMaps.put('Date',System.label.Date);
      labelMaps.put('ph_transactionType',System.label.ph_transactionType);
      labelMaps.put('ph_FilingType',System.label.ph_FilingType);
      labelMaps.put('ph_WO',System.label.ph_WO);
      labelMaps.put('ph_Filing',System.label.ph_Filing);
      labelMaps.put('ph_Amount',System.label.ph_Amount);
      labelMaps.put('ph_Status',System.label.ph_Status);
      labelMaps.put('JudgmentAmountDue',System.label.JudgmentAmountDue);
      labelMaps.put('Type',System.label.businessProfile_type);
      labelMaps.put('Mailing Address',System.label.Mailing_Address);
      labelMaps.put('Assignee',System.label.Assignee_Label);
      labelMaps.put('Principal(s)',System.label.Principals);
      labelMaps.put('Principals',System.label.Principals);
      labelMaps.put('Resigning_Agent',System.label.Resigning_Agent);
		labelMaps.put('Agent\'s mobile number',System.label.Agent_s_mobile_number);
      labelMaps.put('Principal\'s email',System.label.Principal_s_email);
	  labelMaps.put('Incorporator Type',System.label.Review_Incorporator_Type);
      labelMaps.put('Address',System.label.Label_Address);
      labelMaps.put('Address_Withdrawal',System.label.brs_maintenance_Address);
      labelMaps.put('Stock Class',System.label.StockTable_Class);
      labelMaps.put('Number of Stocks',System.label.StockTable_NumberOfStocks);
      labelMaps.put('Par Value',System.label.STOCK_CLASSIFICATION_HEADER_ADD_PAR_VALUE);
      labelMaps.put('Terms and Limitations',System.label.StockTable_TermsLimitations);
      labelMaps.put('Agent email',System.label.agent_email);
      labelMaps.put('Agent type',System.label.Agent_type);
      labelMaps.put('Business address',System.label.BusinessaddressStageBFR);
      labelMaps.put('Mailing address',System.label.Mailing_Address);
      labelMaps.put('Residence address',System.label.brs_Residence_Address);
      labelMaps.put('Name',System.label.Name);
      labelMaps.put('Principal type',System.label.Principal_type);
      labelMaps.put('Principal Title',System.label.brs_PrincipalTitle);
      labelMaps.put('Business ALEI',System.label.Business_AELI);
      labelMaps.put('Lien_type_Stage_Name',System.label.Lien_type_Stage_Name);
      labelMaps.put('Select_a_Lien_Type_Stage_Name',System.label.Select_a_Lien_Type_Stage_Name);  
      labelMaps.put('AircraftStageName',System.label.AircraftStageName);  
      labelMaps.put('AssignmentStageName',System.label.AssignmentStageName);  
      labelMaps.put('ComplaintStageName',System.label.ComplaintStageName);  
      labelMaps.put('CollateralStageName',System.label.CollateralStageName);  
      labelMaps.put('DebtorStageName',System.label.DebtorStageName);
      labelMaps.put('Filing_details_StageName',System.label.Filing_details_StageName);
      labelMaps.put('AddDebtorStageName',System.label.AddDebtorStageName);
      labelMaps.put('Secured_PartyStageName',System.label.Secured_PartyStageName);
      labelMaps.put('AddaSecured_PartyStageName',System.label.AddaSecured_PartyStageName);
      labelMaps.put('Lien_assignmentStageName',System.label.Lien_assignmentStageName);
      labelMaps.put('AddCollateralStageName',System.label.AddCollateralStageName);
      labelMaps.put('CollateralDetailStageName',System.label.CollateralDetailStageName);
      labelMaps.put('AddfilingdetailsStageName',System.label.AddfilingdetailsStageName);
      labelMaps.put('FilerreferencedataStageName',System.label.FilerreferencedataStageName);
      labelMaps.put('AlternativedesignationsStageName',System.label.AlternativedesignationsStageName);
      labelMaps.put('linkFindBiz_Summary',System.label.linkFindBiz_Summary);
      labelMaps.put('PaymentStage',System.label.PaymentStage);
      labelMaps.put('OwnerMemberType',System.label.OwnerMemberType);
      labelMaps.put('AddOwner',System.label.AddOwner);
      labelMaps.put('AddAircraft',System.label.AddAircraft);
      labelMaps.put('AddClaimant',System.label.AddClaimant);
      labelMaps.put('BRS_UCC_Judgment_Creditor',System.label.BRS_UCC_Judgment_Creditor);
      labelMaps.put('JudgmentCreditor',System.label.JudgmentCreditor);
      labelMaps.put('Judgment_Debtor_Label',System.label.Judgment_Debtor_Label);
      labelMaps.put('Secured_Part_ies_Label',System.label.Secured_Part_ies_Label);
      labelMaps.put('Debtors_Label',System.label.Debtors_Label);   
	  labelMaps.put('EntityAmendmentTypeStage',System.label.EntityAmendmentTypeStage);

      labelMaps.put('brs_LocationStageVessel',System.label.brs_LocationStageVessel);
      labelMaps.put('JudgmentDebtor',System.label.JudgmentDebtor);
      labelMaps.put('AddanAssigneeStageName',System.label.AddanAssigneeStageName);
      labelMaps.put('JudgmentDetails',System.label.JudgmentDetails);
      labelMaps.put('AddJudgmentDetails',System.label.AddJudgmentDetails);
      labelMaps.put('Vessel_Label',System.label.Vessel_Label);
      labelMaps.put('AddVessel',System.label.AddVessel);
      labelMaps.put('Dispute',System.label.Dispute);
      labelMaps.put('LienLookupHeading',System.label.LienLookupHeading);
       labelMaps.put('Lien_lookup_Stage',System.label.Lien_lookup_Stage);
      labelMaps.put('LienlookupStageName',System.label.LienlookupStageName);
      labelMaps.put('JustifyDispute',System.label.JustifyDispute);
      labelMaps.put('SelectDisputeReason',System.label.SelectDisputeReason);
      labelMaps.put('Label_Submitter_BE',System.label.Label_Submitter_BE);
      labelMaps.put('AddSubmitter',System.label.AddSubmitter);
      labelMaps.put('AmendmenttypeStageName',System.label.AmendmenttypeStageName);
      labelMaps.put('SelectAmendmentType',System.label.SelectAmendmentType);
      labelMaps.put('AmendmentFirstScreen',System.label.AmendmentFirstScreen);
      labelMaps.put('AssignmentFirstScreen',System.label.AssignmentFirstScreen);
      labelMaps.put('Review_MasterLabel_Type_Authorizer',System.label.Review_MasterLabel_Type_Authorizer);
      labelMaps.put('TerminationFirstScreen',System.label.TerminationFirstScreen);
      labelMaps.put('DeleteCollateral',System.label.DeleteCollateral);
      labelMaps.put('RestateCollateral',System.label.RestateCollateral);
      labelMaps.put('AssignCollateral',System.label.AssignCollateral);
      labelMaps.put('ChangeDebtorStageName',System.label.ChangeDebtorStageName);
      labelMaps.put('DeleteDebtorStageName',System.label.DeleteDebtorStageName);
      labelMaps.put('ChangeJudgmentCreditors',System.label.ChangeJudgmentCreditors);
      labelMaps.put('DeleteJudgmentCreditors',System.label.DeleteJudgmentCreditors);
      labelMaps.put('AddJudgmentCreditors',System.label.AddJudgmentCreditors);
      labelMaps.put('BRS_UCC_JudgmentDebtor',System.label.BRS_UCC_JudgmentDebtor);
      
      labelMaps.put('ChangeJudgmentDebtors',System.label.ChangeJudgmentDebtors);
      labelMaps.put('DeleteJudgmentDebtors',System.label.DeleteJudgmentDebtors);
      labelMaps.put('AddJudgmentDebtors',System.label.AddJudgmentDebtors);

      labelMaps.put('ChangeSecuredParties',System.label.ChangeSecuredParties);
      labelMaps.put('DeleteSecuredParties',System.label.DeleteSecuredParties);
      labelMaps.put('AddSecuredParties',System.label.AddSecuredParties);
      labelMaps.put('Liendetails',System.label.Liendetails);
      labelMaps.put('NewLienType',System.label.NewLienType);
      labelMaps.put('DateOfSaleLabelStageName',System.label.DateOfSaleLabelStageName);
      labelMaps.put('AircraftClaimBasisLabelStageName',System.label.AircraftClaimBasisLabelStageName);
      labelMaps.put('AircraftLocationStageName',System.label.AircraftLocationStageName);
      labelMaps.put('AircraftRegistrationnumberStageName',System.label.AircraftRegistrationnumberStageName);
      labelMaps.put('PlaceSaleLabelStageName',System.label.PlaceSaleLabelStageName);
      labelMaps.put('AddAssignor',System.label.AddAssignor);
      labelMaps.put('BRS_UCC_Assignor_Label',System.label.BRS_UCC_Assignor_Label);
      labelMaps.put('Details',System.label.Details);
      labelMaps.put('Attachment',System.label.Attachment);
      labelMaps.put('Trustdetails',System.label.Trustdetails);
      labelMaps.put('CollateralisLabel',System.label.CollateralisLabel);
      labelMaps.put('Lienbeingfiled',System.label.Lienbeingfiled);
      labelMaps.put('judgment_Creditor_Plural',System.label.judgment_Creditor_Plural);
      labelMaps.put('CourtJudgment',System.label.CourtJudgment);
      labelMaps.put('JudgmentDate',System.label.JudgmentDate);
      labelMaps.put('CourtNameLabel',System.label.CourtNameLabel);
      labelMaps.put('JudgementPersonalPropertyStage',System.label.JudgementPersonalPropertyStage);
      labelMaps.put('JudgementOriginalAmountStage',System.label.JudgementOriginalAmountStage);
      labelMaps.put('judgment_Debtor_Plural',System.label.judgment_Debtor_Plural);
      labelMaps.put('VesselDescriptionStage',System.label.VesselDescriptionStage);
      labelMaps.put('ClainAmountStage',System.label.ClainAmountStage);
      labelMaps.put('VesselmanufacturerStage',System.label.VesselmanufacturerStage);
      labelMaps.put('VesselhullNumberLabel',System.label.VesselhullNumberLabel);
      labelMaps.put('Secured_Party_Plural',System.label.Secured_Party_Plural);
      labelMaps.put('BRS_UCC_Owners_Label',System.label.BRS_UCC_Owners_Label);
      labelMaps.put('PrimarydetailsStage',System.label.PrimarydetailsStage);
      labelMaps.put('LegalstructureStage',System.label.LegalstructureStage);
      labelMaps.put('BRSFirstScreen',System.label.BRSFirstScreen);
      labelMaps.put('ConnecticutbusinessnameStage',System.label.ConnecticutbusinessnameStage);
      labelMaps.put('BusinessdescriptionStage',System.label.BusinessdescriptionStage);
      labelMaps.put('Professionalcorporation',System.label.Professionalcorporation);
      labelMaps.put('Businesscategorysurvey',System.label.Businesscategorysurvey);
      labelMaps.put('NAICSselectionStage',System.label.NAICSselectionStage);
      labelMaps.put('NamereservationStage',System.label.NamereservationStage);
	  labelMaps.put('ImportantdatesStage',System.label.ImportantdatesStage);
	  labelMaps.put('Stockclassification',System.label.Stockclassification);
	  labelMaps.put('Businessemail',System.label.Businessemail);
     labelMaps.put('Filer_s_email_address',System.label.Filer_s_email_address);
	  labelMaps.put('MembertypeLabel',System.label.MembertypeLabel);
	  labelMaps.put('businessProfile_bname',System.label.businessProfile_bname);
	  labelMaps.put('Legalacknowledgment',System.label.Legalacknowledgment);
	  labelMaps.put('CertificatesStage',System.label.CertificatesStage);
	  labelMaps.put('NatureActivities',System.label.NatureActivities);

     //Maintenance Flows
     labelMaps.put('brs_Maintenance_PaymentStage',System.label.brs_Maintenance_PaymentStage);
     labelMaps.put('brs_Maintenance_ReviewEditStage',System.label.brs_Maintenance_ReviewEditStage);
     labelMaps.put('brs_Maintenance_SelectBusinessStage',System.label.brs_Maintenance_SelectBusinessStage);
     labelMaps.put('Change_Email_Flow',System.label.Change_Email_Flow);
     labelMaps.put('brs_AgentChange_AgentResumeFirstScreen',System.label.brs_AgentChange_AgentResumeFirstScreen);
     labelMaps.put('brs_Maintenance_KeyContactsStage',System.label.brs_Maintenance_KeyContactsStage);
     labelMaps.put('brs_emailChange_EmailConfirmStage2',System.label.brs_emailChange_EmailConfirmStage2);
     labelMaps.put('brs_emailChange_EmailConfirmStage',System.label.brs_emailChange_EmailConfirmStage);
     labelMaps.put('brs_BusinessAddressChage_LocationScreen1Heading',System.label.brs_BusinessAddressChage_LocationScreen1Heading);
     labelMaps.put('brs_MaintenanceLocationStage',System.label.brs_MaintenanceLocationStage);
      labelMaps.put('brs_InterimPrincipalStage',System.label.brs_InterimPrincipalStage);
      labelMaps.put('brs_AgentChange_AgentScreenHeading',System.label.brs_AgentChange_AgentScreenHeading);
      labelMaps.put('brs_AgentResign_AgentBusinessLocationScreenHeading',System.label.brs_AgentResign_AgentBusinessLocationScreenHeading);
      labelMaps.put('brs_AgentAddressEditStage',System.label.brs_AgentAddressEditStage);
      labelMaps.put('brs_NAICSEditStage',System.label.brs_NAICSEditStage);
      labelMaps.put('brs_BusinessMaintenanceMainFLow_ChangeNAICSCodeFlowTitle2',System.label.brs_BusinessMaintenanceMainFLow_ChangeNAICSCodeFlowTitle2);
      labelMaps.put('brs_NameChangeUpdateBNameStage',System.label.brs_NameChangeUpdateBNameStage);
      labelMaps.put('BRSLLCFirstScreen',System.label.BRSLLCFirstScreen);
      labelMaps.put('brs_NameChangeApprovalVoteStage',System.label.brs_NameChangeApprovalVoteStage);
      labelMaps.put('brs_NameChangeSelectStatementStage',System.label.brs_NameChangeSelectStatementStage);
      labelMaps.put('brs_NameChangeSelectVoteStage',System.label.brs_NameChangeSelectVoteStage);
      labelMaps.put('KeycontactsStage',System.label.KeycontactsStage);	
      labelMaps.put('brs_NameChangeSelectVoteStage',System.label.brs_NameChangeSelectVoteStage);	
      labelMaps.put('brs_NameChangeSelectVoteStage',System.label.brs_NameChangeSelectVoteStage);	
      labelMaps.put('brs_NameChangeSelectVoteStage',System.label.brs_NameChangeSelectVoteStage);
      labelMaps.put('Add_Agent',System.label.Add_Agent);
      labelMaps.put('brs_nameChangeFileUpload',System.label.brs_nameChangeFileUpload);
      labelMaps.put('brs_nameChangeRequiredFiles',System.label.brs_nameChangeRequiredFiles);
      labelMaps.put('brs_Add_Incorporator',System.label.brs_Add_Incorporator);
      labelMaps.put('Change_NAICS_Flow',System.label.Change_NAICS_Flow);
      labelMaps.put('brs_nameChangeFileUpload',System.label.brs_nameChangeFileUpload);
      labelMaps.put('brs_nameChangeRequiredFiles',System.label.brs_nameChangeRequiredFiles);
      labelMaps.put('brs_AgentAddressChangeStage',System.label.brs_AgentAddressChangeStage);
      labelMaps.put('brs_VerifyCert_SelectCertStage',System.label.brs_VerifyCert_SelectCertStage);
      labelMaps.put('BRS_Select_or_search_a_certificate',System.label.BRS_Select_or_search_a_certificate);
      labelMaps.put('brs_VerifyCert_FlowTitle',System.label.brs_VerifyCert_FlowTitle);
      labelMaps.put('BRS_Select_or_search_a_business',System.label.BRS_Select_or_search_a_business);
      labelMaps.put('brs_ObtainCert_CertStage',System.label.brs_ObtainCert_CertStage);
      labelMaps.put('brs_ObtainCert_CertTypeStage',System.label.brs_ObtainCert_CertTypeStage);
      labelMaps.put('brs_RenounceBusiness_RenunciationDetailHeading',System.label.brs_RenounceBusiness_RenunciationDetailHeading);
      labelMaps.put('brs_CloseBusiness_DissolutionDetailStage',System.label.brs_CloseBusiness_DissolutionDetailStage);
      labelMaps.put('brs_CloseBusiness_DissolutionMethodStage',System.label.brs_CloseBusiness_DissolutionMethodStage);
      labelMaps.put('BRS_Close_Business_Address',System.label.BRS_Close_Business_Address);
      labelMaps.put('brs_WithdrawBusiness_WithdrawalDetailHeading',System.label.brs_WithdrawBusiness_WithdrawalDetailHeading);
      labelMaps.put('brs_CloseBusiness_RenunciationDetailStage',System.label.brs_CloseBusiness_RenunciationDetailStage);
      labelMaps.put('brs_RevocationOfDissolution_SelectMethodStage',System.label.brs_RevocationOfDissolution_SelectMethodStage);
      labelMaps.put('brs_RevocationOfDissolution_RevocationDetailStage',System.label.brs_RevocationOfDissolution_RevocationDetailStage);
      labelMaps.put('PeriodOfDuration_valueId',System.label.PeriodOfDuration_valueId);
      
      labelMaps.put('brs_Add_Principal',System.label.brs_Add_Principal);
      labelMaps.put('ReviewsubmissionStage',System.label.ReviewsubmissionStage);
      labelMaps.put('AdditionalDocumentationStage',System.label.AdditionalDocumentationStage);
      labelMaps.put('BusinesslocationStage',System.label.BusinesslocationStage);
      labelMaps.put('AddressjurisdictionStage',System.label.AddressjurisdictionStage);
      labelMaps.put('BusinessaddressStage',System.label.BusinessaddressStage);
      labelMaps.put('Origin',System.label.Origin);
      labelMaps.put('AircraftManufacturerStage',System.label.AircraftManufacturerStage);
      labelMaps.put('NameAircraftStage',System.label.NameAircraftStage);
      labelMaps.put('AircraftDescriptionStage',System.label.AircraftDescriptionStage);
      labelMaps.put('BRS_UCC_Claimants_Label',System.label.BRS_UCC_Claimants_Label);
      labelMaps.put('VesselLength',System.label.VesselLength);
      labelMaps.put('VesselNameStage',System.label.VesselNameStage);
      labelMaps.put('SelectbusinessStage',System.label.SelectbusinessStage);
      labelMaps.put('BusinessaddressStageBFR',System.label.BusinessaddressStageBFR);
      
      labelMaps.put('Financial_Statement_NumberStage',System.label.Financial_Statement_NumberStage);
      labelMaps.put('ReasonfordisputeStage',System.label.ReasonfordisputeStage);
      labelMaps.put('Requestedamendment',System.label.Requestedamendment);
      labelMaps.put('Disputejustification',System.label.Disputejustification);
      labelMaps.put('RequestAmendment',System.label.RequestAmendment);
      labelMaps.put('ExistingLienInformation',System.label.ExistingLienInformation);
      labelMaps.put('UpdatedDebtorJudgmentInformationStage',System.label.UpdatedDebtorJudgmentInformationStage);
      labelMaps.put('AddedJudgmentDebtorStage',System.label.AddedJudgmentDebtorStage);
      labelMaps.put('PreviousJudgmentDebtorInformationStage',System.label.PreviousJudgmentDebtorInformationStage);


      labelMaps.put('DeletedDebtorStage',System.label.DeletedDebtorStage);
      labelMaps.put('AddedSecuredStage',System.label.AddedSecuredStage);
      labelMaps.put('UpdatedSecuredInformation',System.label.UpdatedSecuredInformation);
      labelMaps.put('PreviousSecuredInformation',System.label.PreviousSecuredInformation);
      labelMaps.put('DeletedSecuredStage',System.label.DeletedSecuredStage);
      labelMaps.put('AddedOwner',System.label.AddedOwner);
      labelMaps.put('FinancialStatementNumberStage',System.label.FinancialStatementNumberStage);
      labelMaps.put('CollateralAttachmentStage',System.label.CollateralAttachmentStage);
      labelMaps.put('AssigneeLabel',System.label.AssigneeLabel);

      labelMaps.put('AddedJudgmentCreditorStage',System.label.AddedJudgmentCreditorStage);
      labelMaps.put('UpdatedJudgmentCreditorInformation',System.label.UpdatedJudgmentCreditorInformation);
      labelMaps.put('DeletedJudgmentCreditorStage',System.label.DeletedJudgmentCreditorStage);
      labelMaps.put('PreviousJudgmentCreditorInformation',System.label.PreviousJudgmentCreditorInformation);
      labelMaps.put('FilerreferencedataStageName',System.label.FilerreferencedataStageName);
      labelMaps.put('PreviousDebtorInformationStage',System.label.PreviousDebtorInformationStage);
      labelMaps.put('UpdatedDebtorInformationStage',System.label.UpdatedDebtorInformationStage);
      labelMaps.put('AddedDebtorStage',System.label.AddedDebtorStage);
      labelMaps.put('DeletedJudgmentDebtorStage',System.label.DeletedJudgmentDebtorStage);


      labelMaps.put('Amendment_Label',System.label.Amendment_Label);
      labelMaps.put('OriginalLapseDate',System.label.OriginalLapseDate);
      labelMaps.put('lapse_Date',System.label.lapse_Date);
      labelMaps.put('CollateralAmendmentTypeStage',System.label.CollateralAmendmentTypeStage);
      labelMaps.put('FilerreferencedataStageName',System.label.FilerreferencedataStageName);
      labelMaps.put('BRS_Location_JurisdictionOffice',System.label.BRS_Location_JurisdictionOffice);
      labelMaps.put('Mailing_Address',System.label.Mailing_Address);
      labelMaps.put('Stateofformation',System.label.Stateofformation);
      labelMaps.put('Countryofformation',System.label.Countryofformation);
      labelMaps.put('brs_IncorporatorsLabel',System.label.brs_IncorporatorsLabel);
     labelMaps.put('MailingJurisdictionStateofFormation',System.label.MailingJurisdictionStateofFormation);
       labelMaps.put('ForeignALEI',System.label.ForeignALEI);


      labelMaps.put('principal_radio',System.label.principal_radio);
      labelMaps.put('businessProfile_email',System.label.businessProfile_email);
      labelMaps.put('Businesspurpose',System.label.Businesspurpose);
      labelMaps.put('DatebegantransactingStage',System.label.DatebegantransactingStage);
      labelMaps.put('DateofformationStage',System.label.DateofformationStage);
      labelMaps.put('DescriptionStage',System.label.DescriptionStage);
      labelMaps.put('ElectionofBenefitSubtext',System.label.ElectionofBenefitSubtext);
      labelMaps.put('NAICSinformation',System.label.NAICSinformation);
	  labelMaps.put('brs_NAICSinformation',System.label.brs_NAICSinformation);
      labelMaps.put('Otherprovisions',System.label.Otherprovisions);
      labelMaps.put('BRS_BusinessNameInFormation',System.label.BRS_BusinessNameInFormation);
      labelMaps.put('VesselpropulsionStage',System.label.VesselpropulsionStage);
      
      
      labelMaps.put('TOTAL_AUTHORIZED_SHARES',System.label.TOTAL_AUTHORIZED_SHARES);
      labelMaps.put('PrincipalOfficeAddress',System.label.PrincipalOfficeAddress);
	  labelMaps.put('BRS_ReviewClassMembers',System.label.BRS_ReviewClassMembers);
      labelMaps.put('BRS_ReviewMemberType',System.label.BRS_ReviewMemberType);
       labelMaps.put('brs_BusinessAddressChage_ReviewScreenHeadingbrs_EmailChage_ReviewScreen',System.label.brs_BusinessAddressChage_ReviewScreenHeadingbrs_EmailChage_ReviewScreen);
       labelMaps.put('location',System.label.location);
       labelMaps.put('Email_Address',System.label.Email_Address);
       labelMaps.put('brs_Dateoforganizationmeeting',System.label.brs_Dateoforganizationmeeting);
       labelMaps.put('BRS_Select_or_search_a_business',System.label.BRS_Select_or_search_a_business);
       labelMaps.put('SelectbusinessStage',System.label.SelectbusinessStage);
       labelMaps.put('Filings_Due',System.label.Filings_Due);
       labelMaps.put('BRS_Close_Business_Review_Edit',System.label.BRS_Close_Business_Review_Edit);
       labelMaps.put('Agent',System.label.Agent);
       labelMaps.put('Statecertificate',System.label.Statecertificate);
       labelMaps.put('Legalacknowledgmentcertificate',System.label.Legalacknowledgmentcertificate);
       labelMaps.put('select_Business_Heading',System.label.select_Business_Heading);
	   
	   // Labels for copy request
       labelMaps.put('Business_Copy_Type_Description',System.label.Business_Copy_Type_Description);
       labelMaps.put('UCC_Liens_Label',System.label.UCC_Liens_Label);
       labelMaps.put('UCC_Copy_Type_Description',System.label.UCC_Copy_Type_Description);
       labelMaps.put('select_filings_for_copy_request',System.label.select_filings_for_copy_request);
       labelMaps.put('select_filings',System.label.select_filings);
       labelMaps.put('select_type_of_copies',System.label.select_type_of_copies);
       labelMaps.put('filing_information',System.label.filing_information);
       labelMaps.put('Filing_Information_Header',System.label.Filing_Information_Header);
       labelMaps.put('Filing_Information_Mailing_Header',System.label.Filing_Information_Mailing_Header);
       labelMaps.put('Select_or_search_business',System.label.Select_or_search_business);
       labelMaps.put('businessProfile_maddress',System.label.businessProfile_maddress);
       labelMaps.put('Review_edit',System.label.Review_edit);
       labelMaps.put('Copy_Type_Label',System.label.Copy_Type_Label);
       labelMaps.put('Select_copy_type_label',System.label.Select_copy_type_label);
       labelMaps.put('Enter_filing_numbers_label',System.label.Enter_filing_numbers_label);
       labelMaps.put('Review_MasterLabel_Type_Debtor',System.label.Review_MasterLabel_Type_Debtor); 
       labelMaps.put('filing_number_search',System.label.filing_number_search); 
       labelMaps.put('debtor_information',System.label.debtor_information);
       labelMaps.put('Enter_mailing_address',System.label.Enter_mailing_address);
	   labelMaps.put('foreignInv_DetailsSection',System.label.foreignInv_DetailsSection);
       labelMaps.put('foreignInv_DetailsSubSection',System.label.foreignInv_DetailsSubSection);
       labelMaps.put('foreignInv_MethodPaymentSection',System.label.foreignInv_MethodPaymentSection);
       labelMaps.put('foreignInv_MethodPaymentSubSection',System.label.foreignInv_MethodPaymentSubSection);
	   labelMaps.put('Business Name',System.label.business_name);
       labelMaps.put('Approval/Vote',System.label.brs_NameChangeApprovalVoteStage);
       labelMaps.put('Vote Information',System.label.brs_DomesticNameChange_VoteInformationScreenHeader);
       labelMaps.put('Statement of Approval',System.label.brs_DomesticNameChange_StatementOfApprovalScreenSubHeading);
       labelMaps.put('Copy_Type_Label',System.label.Copy_Type_Label);
	   labelMaps.put('The amendment was duly approved by the members in the manner required by sections 33-1140 to 33-1147 of the Connecticut general statutes, and by the certificate in incorporation.',System.label.brs_DomesticNameChange_VoteInformationScreenOption1);
	  labelMaps.put('The amendment was duly approved by the incorporators and members approval was not required.',System.label.brs_DomesticNameChange_VoteInformationScreenOption2);
	  labelMaps.put('The amendment was duly approved by the board of directors and member approval was not required.',System.label.brs_DomesticNameChange_VoteInformationScreenOption3);
	  
	  labelMaps.put('The amendment was approved by shareholders in the manner required by sections 33-600 to 33-998 of the Connecticut general statutes, and by the certificate of incorporation.',System.label.brs_DomesticNameChange_StatementOfApprovalScreenOption1);
	  labelMaps.put('The amendment was approved by the incorporators. No shareholder approval as required.',System.label.brs_DomesticNameChange_StatementOfApprovalScreenOption2);
	  labelMaps.put('The amendment was approved by the board of directors. No shareholders approval was required.',System.label.brs_DomesticNameChange_StatementOfApprovalScreenOption3);
	  labelMaps.put('The amendment was approved by a minimum status vote. As required by the Connecticut Benefit Corporation Act. Selected if a minimum status vote resulted in the election of Benefit Corporation Status.',System.label.brs_DomesticNameChange_StatementOfApprovalScreenOption4);

     labelMaps.put('Business_name',System.label.business_name);
     labelMaps.put('Add_your_business_name',System.label.Add_your_business_name);
     labelMaps.put('Review_edit_Nameres',System.label.brs_Maintenance_ReviewEditStage);

     labelMaps.put('Amount',System.label.Amount);

     labelMaps.put('Effective_Date_of_Dissolution',System.label.brs_DissolveBusiness_DissolutionDetailScreenDateLabel);
     labelMaps.put('Authorized_Date_of_Dissolution',System.label.Authorized_Date_Dissolution);
     labelMaps.put('Method_of_Dissolution',System.label.Method_of_Dissolution);
     labelMaps.put('Effective_Time_of_Dissolution',System.label.brs_DissolveBusiness_DissolutionDetailScreenTimeLabel);
     labelMaps.put('Effective_Date_of_Renunciation',System.label.Effective_Date_Renunciation);
     labelMaps.put('Effective_Date_of_Withdrawal',System.label.Effective_Date_Withdrawal);
     labelMaps.put('Effective_Time_of_Withdrawal',System.label.Effective_Time_Withdrawal);
     labelMaps.put('Date_of_Dissolution',System.label.Date_Dissolution);
     labelMaps.put('Debtor_Label_Review_page',System.label.DebtorStageName);

     labelMaps.put('brs_RevocationOfDissolution_RevocationDetailStage',System.label.brs_RevocationOfDissolution_RevocationDetailStage);
     labelMaps.put('brs_RevocationOfDissolution_SelectMethodStage',System.label.brs_RevocationOfDissolution_SelectMethodStage);     
     labelMaps.put('Date_of_Dissolution',System.label.Date_Dissolution);
     labelMaps.put('Debtor_Label_Review_page',System.label.DebtorStageName);
     
     labelMaps.put('brs_RevocationOfDissolution_RevocationDetailStage',System.label.brs_RevocationOfDissolution_RevocationDetailStage);
     labelMaps.put('brs_RevocationOfDissolution_SelectMethodStage',System.label.brs_RevocationOfDissolution_SelectMethodStage);
     labelMaps.put('Authorized_date_of_Revocation',System.label.AuthDateOfRevocation);
     labelMaps.put('business_name_search',System.label.business_name_search);
     
	     labelMaps.put('rc_Category',System.label.rc_Category);
  
      labelMaps.put('brs_Filing_upload',System.label.brs_Filing_upload);
      labelMaps.put('brs_FilingDetailsStage',System.label.brs_FilingDetailsStage);
     labelMaps.put('IntakeReviewStage',System.label.IntakeReviewStage);
     labelMaps.put('SelectCategoryStage',System.label.SelectCategoryStage);
     
     labelMaps.put('brs_LegalStructure',System.label.brs_LegalStructure);

          labelMaps.put('Secured_Part_ies_Label_Review_Page',System.label.Secured_Part_ies_Label_Review_Page);
     labelMaps.put('Type',System.label.Type);
     labelMaps.put('Attachments',System.label.Attachment);
     labelMaps.put('Assignee',System.label.AssigneeLabel);
     labelMaps.put('Select_an_Amendment_Type',System.label.SelectAmendmentType);

     labelMaps.put('Method_of_Revocation',System.label.Method_of_Revocation);

       return labelMaps;

   }
}