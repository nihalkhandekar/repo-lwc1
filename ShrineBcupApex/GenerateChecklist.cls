/******************************************************************************************************************************************
 * NAME:  GenerateChecklist
 * DESCRIPTION: This class pulls the responses from the Questionnaire process and generate a checklist based on the data from the checklist master
 *
 * @AUTHOR: Sabhyata Rao
 * @DATE: 31/03/2020
 *
 *
 * MODIFICATION LOG
 * DEVELOPER                         DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------------------------
 * Sabhyata Rao                     31/03/2020                         Created the first version
 * Sabhyata Rao                     26/04/2020                         Modification for CTBOS 544 & CTBOS 460
 * Shreya Bordia                    27/07/2020                         CTBOS-3369 | Remove custom label usage
 * Shreya Bordia                    20/08/2020                         CTBOS-250 | Multi-lingual
 ***************************************************************************************************************************************************/
public without sharing class GenerateChecklist {
    private static final String COMMA_SPLIT = ',';
    private static final String SPACE = ' ';
    private static final String PIPE = '|';
    private static final String LANGUAGE_FIELD = 'Language__c';
    private static final String TO_LABEL = 'toLabel';
    //For URL language => internal lang mismatch
    private static final Map<String, String> mapLanguageMismatch = new Map<String, String>{
        'pt_BR' => 'pt-PT',
        'zh_CN' => 'zh-CN'
    };
    
    /********************************************************************************************
        METHOD NAME    : validateChecklistItemAccess
        DESCRIPTION    : This method recieve the Questionnaire ID and performs query on Questionnaire__c 
        and User object to compare logged in users Contact ID and Questionnaire Contact ID to validate access
        for checklist/questionnaire.
        RETURN TYPE    : boolean
        PARAMETER      : ID questionnaireId
    ********************************************************************************************/
    @AuraEnabled
    public static boolean validateChecklistItemAccess(String questionnaireId) {
        List<Questionnaire__c> quest = new List<Questionnaire__c>();
        ID UserID = userInfo.getUserID();
        ID userContactID;
        User u;
        if(questionnaireId != Null){
            quest = [Select ID,Contact__c from Questionnaire__c where ID=:questionnaireId];
        }
        if(UserID != Null){
            u = [Select ID,ContactID from user where ID=: UserID];
            if(u != Null && u.ContactID != Null){
                userContactID = u.ContactID;
            }
        }
        if(quest != Null && !quest.isEmpty() && quest.Size()>0 && quest[0].Contact__c == userContactID){
            return true;
        }
        else{
            return false;
        }
    }
    
    /********************************************************************************************
        METHOD NAME    : generateChecklistItem
        DESCRIPTION    : This method recieve the Questionnaire ID and FlowId nd perform query on QnA_QuestionResponse__c
        Object and fetch all responses and check for all the questions having Checklist Master related.
        If Checklist Master is associated then fetch the associated template for the corresponding response 
        for that question.
        RETURN TYPE    : void
        PARAMETER      : ID questionnaireId
    ********************************************************************************************/
    @AuraEnabled
    public static Checklist generateChecklistItem(String questionnaireId, String language) {
        //Step 1 | Get ques & their ans
        Checklist checklist;
        Map<Id, String> mapQuesAnswer = new Map<Id, String>();
        //Step 2 | Get metadata resources
        Map<String, ResourceWrapper> mapTypeResWrapper = new Map<String, ResourceWrapper>();
        //Step 3 | Get checklist masters
        Set<Id> parentChecklistIds = new Set<Id>();
        Map<Id, Checklist_Master__c> mapChecklistMasters = new Map<Id, Checklist_Master__c>();
        Map<Id, List<Checklist_Master__c>> mapParenttoChildChecklist = new Map<Id, List<Checklist_Master__c>>();
        Set<Id> checkListIds = new Set<Id>();
        //Step 5 | Filter CM based on response
        Map<Id, TemplateChecklistItems__c> mapTemplateChecklistItem;
        Map<String, Map<String, TemplateChecklist>> mapCategoryToTemplateWrapper = new Map<String, Map<String, TemplateChecklist>>();
        
        if(language == null ){
            language  = UserInfo.getLocale();

            Map<String,String> codes = new Map<String,String>();

            Wizard_Utlity.languageOption options = Wizard_Utlity.languageTranslationCode();
for(Language_Mapping__mdt option :options.languageOptions){
    codes.put(option.Salesforce_Language_code__c, option.Google_Language_Code__c);
}
codes.put('en_US','en_US');
language=codes.get(language);
 }
        //CTBOS-4028 | Lang mismatch
        language = mapLanguageMismatch.containsKey(language) ? mapLanguageMismatch.get(language) : language;
        
        //Step 1. If pre-existing | No changes
        /*
         * Fetch the reponse upserted
         * If any answer which is marked as required and response is NULL then throw exception
         * Else map the Question with Given Response
        **/
        if(String.isNotBlank(questionnaireId)) {
            for(QnA_QuestionResponse__c questionResponse: getQuestionResponses(questionnaireId)) {
                //i. Pre-existing | return
                if(String.isNotBlank(questionResponse.Questionnaire__r.JSON_Response__c)) {
                    checklist = (Checklist) System.JSON.deserialize(questionResponse.Questionnaire__r.JSON_Response__c, Checklist.class);
                    checklist.isGeneratedFirstTime = false;
                    return checklist;
                }
                //ii. Required | throw error
                else if(questionResponse.Question__r.Required__c && String.isBlank(questionResponse.Given_Response_Value__c)) {
                    throw new AuraHandledException(System.Label.REQUIRED_EXCEPTION_MSG);
                }
                //iii. New Checklist | CTBOS-3389 | compare with english version
                else {
                    String ans = questionResponse.Given_Response_Value__c 
                        + (String.isNotBlank(questionResponse.Other_Short_value__c) ? PIPE + questionResponse.Other_Short_value__c : '');
                    mapQuesAnswer.put(questionResponse.Question__c, ans);
                }

                //One time only
                if(checklist == null) {
                    checklist = new Checklist(questionResponse);
                }
            }
        }
        
        if(mapQuesAnswer.IsEmpty()) {
            return checklist;
        }
        //Step 1. Ends

        //Step 2. Framework Question | CTBOS-3369 Changes*
        /*
         * Map the Question id to the given response,the map is basically a subset of mapQuesAnswer
         * off all the questions having a checklist
        */
        Map<String, Checklist_Mapping__mdt> mapTypeChecklistMapping = getChecklistMapping();
            
        for(QnA_FrameworkQuestion__c question: getFrameworkQuestions(mapQuesAnswer.keySet(), language)) {
            //i. CTBOS-3389 | Get Options for ques | changes*
            //ii. Business Name | Resolved - through Questionnaire

            //iii. Get Resources | CTBOS-3369 *Changes
            if(!question.Checklist_Masters__r.isEmpty()) {
                String resourceType = question.Checklist_Masters__r.get(0).Resource__c;
                
                if(String.isNotBlank(resourceType) && mapTypeChecklistMapping.containsKey(resourceType)) {
                    String ans = mapQuesAnswer.get(question.id);

                    //v. Towns
                    if(!question.Followup_Questions__r.isEmpty()) {
                        ans += mapQuesAnswer.containsKey(question.Followup_Questions__r.get(0).Id) 
                            ? PIPE + mapQuesAnswer.get(question.Followup_Questions__r.get(0).Id) 
                            : '';
                    }
                    
                    //vi. Group Identification | Resolved in getResponse()
                    
                    //vii. license has 2 types of inputs
                    if(mapTypeResWrapper.containsKey(resourceType)) {
                        mapTypeResWrapper.get(resourceType).mapTypeResponse.put(question.AnswerElement__c, ans);
                    } else {
                        mapTypeResWrapper.put(
                            resourceType, new ResourceWrapper(mapTypeChecklistMapping.get(resourceType), ans, question.AnswerElement__c)
                        );
                    }
                }
            }
        }

        /*
            CTBOS-3369 | Get Records | Eg: Municipality_Information__mdt -> Hartford|New Haven
            For resources: if no ans -> get default ones
        */
        for(ResourceWrapper resource :mapTypeResWrapper.values()) {
            resource.listRecords = getRecords(resource, language); 
        }
        //Step 2 Ends

        //Step 3. Child Checklist Master | No change
        /*
         * Fetch the checklist master for the question which has a checklist master associated to them
         * In case of parent-child checklist, the parent checklist would not be picked up in listChecklistMaster
         * only child checklist would be picked up
        */
        //Fetch the parent id to get parent checklist record   
        for(Checklist_Master__c checklistMaster :getChecklistMasterByQuestion(mapQuesAnswer.keySet(), language)) {
            //i. Get parent checklist
            if(checklistMaster.Checklist_Master_Parent__c != null) {
                parentChecklistIds.add(checklistMaster.Checklist_Master_Parent__c);
            }

            //ii. If isStaticCI
            if(checklistMaster.Include_as_Static_Checklist_Item__c) {
                checkListIds.add(checklistMaster.Checklist_Template_Items__c);
            }

            mapChecklistMasters.put(checklistMaster.Id, checklistMaster);
        }
        
        //Parent Checklist Master | No change
        for(Checklist_Master__c checklistMaster: getChecklistMasterByParent(parentChecklistIds, language)) {
            if(!mapParenttoChildChecklist.containsKey(checklistMaster.Checklist_Master_Parent__c)) {
                mapParenttoChildChecklist.put(checklistMaster.Checklist_Master_Parent__c, new List<Checklist_Master__c>());
            }

            mapParenttoChildChecklist.get(checklistMaster.Checklist_Master_Parent__c).add(checklistMaster);
        }
        //Step 3. Ends

        //Step 4. Get checklist by Answer UI Element | No change
        /*
        * If the given response is same as Needed Response then get the corresponding template should be picked
        * In case of parent-child checklist, parent checklist will not have a question & a Needed response
        * Also, parent child concept will work if both the child checklist question were part of the questionnaire
        * process AND for both of them given response is the needed response.
        * Child question will only evaluated if the check child records on parent is checked
        * */       
        for(Checklist_Master__c checklistMaster :mapChecklistMasters.values()) {
            //iii. Get checklist category on the template item
            if(checklistMaster.Checklist_Master_Parent__c != null) { 
                Integer countQuestionAnswered = 0;
                Integer pickParentTemplate = 0;
                
                //get the child checklist
                List<Checklist_Master__c> listChildChecklist = mapParenttoChildChecklist.get(checklistMaster.Checklist_Master_Parent__c);

                if(!listChildChecklist.isEmpty()) {
                    //A. check if both child question are present in the flow
                    for(Checklist_Master__c childChecklistMaster :listChildChecklist) {
                        if(mapQuesAnswer.containsKey(childChecklistMaster.QA_Question__c)) {
                            countQuestionAnswered++;
                        }
                    }
    
                    //B. if both the question were part of flow and checkbox on parent checkbox is true
                    if(countQuestionAnswered == listChildChecklist.size() 
                        && checklistMaster.Checklist_Master_Parent__r.Check_child_records__c 
                        && !checklistIds.contains(checklistMaster.Checklist_Master_Parent__r.Checklist_Template_Items__c)
                    ) {                        
                        for(Checklist_Master__c childChecklistMaster: listChildChecklist) {
                            String neededResponses = childChecklistMaster.English_Version__c != null
                                ? childChecklistMaster.English_Version__r.Needed_Response__c
                                : childChecklistMaster.Needed_Response__c;

                            if(String.isNotBlank(neededResponses) && mapQuesAnswer.containsKey(childChecklistMaster.QA_Question__c)) {
                                List<String> listGivenResponses = mapQuesAnswer.get(childChecklistMaster.QA_Question__c).split(System.Label.PIPELINE_SEPARATOR); 

                                for(String neededResponse: neededResponses.split(System.Label.PIPELINE_SEPARATOR)) {
                                    if(listGivenResponses.contains(neededResponse)) {
                                        pickParentTemplate++;                                        
                                    }
                                }
                            }

                            if(pickParentTemplate == listChildChecklist.size()) {
                                checkListIds.add(checklistMaster.Checklist_Master_Parent__r.Checklist_Template_Items__c);
                                break;
                            }
                        }
                    }
                }
            } else if(!checkListIds.contains(checklistMaster.Checklist_Template_Items__c) && mapQuesAnswer.containsKey(checklistMaster.QA_Question__c)) {
                String neededResponses = checklistMaster.English_Version__c != null
                    ? checklistMaster.English_Version__r.Needed_Response__c
                    : checklistMaster.Needed_Response__c; 

                //Single & Multi-select
                if(String.isNotBlank(neededResponses)) {
                    List<String> listGivenResponses = mapQuesAnswer.get(checklistMaster.QA_Question__c).split(System.Label.PIPELINE_SEPARATOR); 

                    for(String neededResponse: neededResponses.split(System.Label.PIPELINE_SEPARATOR)) {
                        if(listGivenResponses.contains(neededResponse)) {
                            checkListIds.add(checklistMaster.Checklist_Template_Items__c);
                            break;
                        }
                    }
                }
                //CTBOS : 109 to fetch templates for input answer question, checklist will have needed response as null for such questions
                else if(
                        checklistMaster.QA_Question__r.AnswerElement__c == System.Label.Answer_Element_Search_Input ||
                        checklistMaster.QA_Question__r.AnswerElement__c == System.Label.Answer_Element_Lightning_Input ||
                        checklistMaster.QA_Question__r.AnswerElement__c == System.Label.Answer_Element_Search_Browse
                ) { 
                    checkListIds.add(checklistMaster.Checklist_Template_Items__c);
                }
            }
        }
        //Step 4. Ends

        //Step 5. Put resources into Template | CTBOS-3369 *Changes
        /**
         * Map category to list of template.
         * Providing display order on template will sort the template on the UI
         * Append town details & NAICS codes in respective template.
         * Append the resource data in the respective template.
         * */
        //Fetch Template checklist Item    
        mapTemplateChecklistItem = getTemplateChecklistItems(checkListIds, language);
        
        //**For no license
        for(TemplateChecklistItems__c template: mapTemplateChecklistItem.values()) { 
            if(template.Checklist_Category__c == 'Licenses') {
                //does not contain licenses & template is the 1+licenses
                if(!mapTypeResWrapper.containsKey(System.Label.Subsection_Id_Licenses) && !template.BOS_Checklists__r.isEmpty()) {
                    mapTemplateChecklistItem.remove(template.Id);
                } 
                //contains licenses & template is the 0licenses
                else if(mapTypeResWrapper.containsKey(System.Label.Subsection_Id_Licenses) && template.BOS_Checklists__r.isEmpty()) {
                    mapTemplateChecklistItem.remove(template.Id);
                }
            }
        }
           
        for(TemplateChecklistItems__c templateItem: mapTemplateChecklistItem.values()) {
            TemplateChecklist templateChecklistWrapper = new TemplateChecklist(templateItem);
            
            //i. Towns, ii. NAICS, iii. Licenses, iv. Services
            String resType = !templateItem.BOS_Checklists__r.isEmpty() && String.isNotBlank(templateItem.BOS_Checklists__r[0].Resource__c)
                ? templateItem.BOS_Checklists__r[0].Resource__c
                : '';

            if(mapTypeResWrapper.containsKey(resType)) {
                ResourceWrapper res = mapTypeResWrapper.get(resType);
                
                //v. Resources
                if(String.isNotBlank(res.checklistMap.Group_By__c)) {
                    templateChecklistWrapper = getChecklistResources(res, templateItem);
                } else {
                    templateChecklistWrapper = getTemplateChecklist(res, templateItem);
                }
            }
            
            //v. Add to map | No change
            if(String.isNotBlank(templateItem.Checklist_Category__c)) {
                if(!mapCategoryToTemplateWrapper.containsKey(templateItem.Checklist_Category__c)) {
                    mapCategoryToTemplateWrapper.put(templateItem.Checklist_Category__c, new Map<String, TemplateChecklist>());
                }

                mapCategoryToTemplateWrapper.get(templateItem.Checklist_Category__c).put(templateChecklistWrapper.subHeading, templateChecklistWrapper);
            }
        }
        //Step 5. Ends

        //Step 6. Create Checklist | No change
        //i. Add Category
        if(!mapCategoryToTemplateWrapper.isEmpty()) {
            List<Section> listSection = new List<Section>();
            Map<String, String> mapCategories = getChecklistCategories(language);

            for(String category : mapCategories.keySet()) {
                listSection.add(new Section(category, mapCategories.get(category), mapCategoryToTemplateWrapper.get(mapCategories.get(category)).values(),questionnaireId,language));
            }

            checklist.section = listSection;
        }
        //Step 6. Ends
        if(String.isNotBlank(questionnaireId)) {
        //Step 7. update questionnaire | CTBOS-3369 *Changes
        update (new Questionnaire__c(
            id = questionnaireId, 
            Status__c = System.label.Questionnaire_Status_Update, 
            Business_Name__c = checklist.businessName, 
            Checklist_generate_date__c = System.now(), 
            JSON_Response__c = JSON.serialize(checklist)
        ));
        }
        //create task
        createTask(questionnaireId, mapTemplateChecklistItem, mapTypeResWrapper);
        //Step 7. Ends
        
        return checklist;
    }

    /**
     * @desc : This method is used to create task on questionnaire when checklist s generated
     * @return : void
     * @created: 22/05/2020    Sabhyata Rao     Initial Development
     * @update : CTBOS-3369 | Step 8.
     */
    @TestVisible
    private static void createTask(Id questionnaireId, Map<Id, TemplateChecklistItems__c> mapTemplateChecklistItem, Map<String, ResourceWrapper> mapTypeResWrapper) {
        String NEW_LINE = '\n';
        List<Task> listTasks = new List<Task>();
        
        for (TemplateChecklistItems__c templateItem: mapTemplateChecklistItem.values()) {
            Task newTask = new Task(
                OwnerId = UserInfo.getUserId(),
                Subject = templateItem.Checklist_Item_Name__c,
                Status = System.Label.TASK_STATUS,
                Priority = System.Label.TASK_PRIORITY,
                TaskSubtype = System.Label.TASK_SUBTYPE,
                fees__c = templateItem.Id,
                WhatId = questionnaireId
            );

            newTask.Description = String.isNotBlank(templateItem.Additional_Detail_Information__c) 
                ? templateItem.Additional_Detail_Information__c.replaceAll('\\<.*?\\>', '').replaceAll('<[/a-zAZ0-9]*>', '')
                : '';              

            //TOWNS
            if(mapTypeResWrapper.containsKey(System.Label.Subsection_Id_Towns)) {
                for(Municipality_Information__mdt town :(List<Municipality_Information__mdt>) mapTypeResWrapper.get(System.Label.Subsection_Id_Towns).listRecords) {
                    //Town of + Andover
                    newTask.Description += town.City_Town_2__c + SPACE + town.City_Town__c + NEW_LINE
                        //17, Main Street
                        + town.StreetAddress__c + NEW_LINE
                        //City
                        + town.City_Town__c + NEW_LINE
                        + town.State__c + NEW_LINE
                        + town.Zip_Code__c + NEW_LINE
                        + town.Municipality_URL__c + NEW_LINE;
                }
            }

            //NAICS CODE
            if(mapTypeResWrapper.containsKey(System.Label.Subsection_Id_NAICS_Code)) {
                for (Category__c category :(List<Category__c>) mapTypeResWrapper.get(System.Label.Subsection_Id_NAICS_Code).listRecords) {
                    newTask.Description += System.Label.Your_NACS_Code_Static_Text + category.Title__c 
                        //Category Code
                        + System.Label.Open_Bracket + category.Code__c + System.Label.Close_Bracket + NEW_LINE 
                        //Parent Category Title
                        + System.Label.Your_NACS_Subcode_Static_Text + category.Parent_Category__r.Parent_Category__r.Parent_Category__r.Title__c 
                        //Parent Category Code
                        + System.Label.Open_Bracket + category.Parent_Category__r.Parent_Category__r.Parent_Category__r.Code__c + System.Label.Close_Bracket + NEW_LINE;
                }
            }

            //RESOURCES
            if(mapTypeResWrapper.containsKey(System.Label.Subsection_Id_Resources)) {
                Map<String, List<Resources_Data__mdt>> mapResources = getMapResources(
                    mapTypeResWrapper.get(System.Label.Subsection_Id_Resources).checklistMap.Group_By__c, 
                    mapTypeResWrapper.get(System.Label.Subsection_Id_Resources).listRecords);

                for(String resourceType : mapResources.keySet()) {
                    newTask.Description += resourceType + NEW_LINE;
                    
                    for (Resources_Data__mdt resource: mapResources.get(resourceType)) {
                        newTask.Description += resource.Title_of_Resource__c + NEW_LINE
                            + resource.Phone__c + NEW_LINE;
                    }
                }
            }

            //LICENSES
            if(mapTypeResWrapper.containsKey(System.Label.Subsection_Id_Licenses)) {
                for(Service__c service :(List<Service__c>) mapTypeResWrapper.get(System.Label.Subsection_Id_Licenses).listRecords) {
                    newTask.Description += String.isNotBlank(service.Licenses_Details__c) 
                        ? service.Licenses_Details__c.replaceAll('\\<.*?\\>', '') + NEW_LINE 
                        : SPACE;
                }
            }

            listTasks.add(newTask);
        }

        if (!listTasks.isEmpty() ) {
            try {
                insert listTasks;                
            } catch(Exception e) {
                BOS_Utility.ExceptionHandler('GenerateChecklist', 'createTask', 'Questionnaire__c', questionnaireId, null, e, null);
            }
        }
    }   

    @TestVisible
    private static Map<String, List<sObject>> getMapResources(String grouperField, List<sObject> listRecords) {
        Map<String, List<sObject>> mapGroupedListRecords = new Map<String, List<sObject>>();
        
        for(sObject record :listRecords) {
            if(!mapGroupedListRecords.containsKey((String)record.get(grouperField))) {
                mapGroupedListRecords.put((String)record.get(grouperField), new List<sObject>());
            }
            mapGroupedListRecords.get((String)record.get(grouperField)).add(record);
        }

        return mapGroupedListRecords;
    }

    /**
     * @update: CTBOS-3389 | 31/8/20
     */
    private static List<QnA_QuestionResponse__c> getQuestionResponses(Id questionnaireId) {
        List<QnA_QuestionResponse__c> listQuestionResponses = new List<QnA_QuestionResponse__c>();
        
     //   if(Schema.SObjectType.QnA_QuestionResponse__c.isAccessible()) {
            listQuestionResponses = [
                SELECT Id, Question__c, Question__r.QuestionBody__c, Question__r.Required__c, Given_Response_Value__c, Other_Short_value__c, 
                    Questionnaire__c, Questionnaire__r.Business_Name__c, Questionnaire__r.Name, Questionnaire__r.CreatedDate, Questionnaire__r.JSON_Response__c
                FROM QnA_QuestionResponse__c
                WHERE Questionnaire__c =: questionnaireId
                //WITH SECURITY_ENFORCED
                LIMIT :BOS_Utility.getAvailableQueryLimit()
            ];
       // }

        return listQuestionResponses;
    }

    /**
     * @created: 27/7/20 | CTBOS-3369
     * @desc: Get framework questions based on questionnaire
     *       Resolved Label.Decsription_matching_business with Checklist_Master__c.Include_as_Static_Checklist_Item__c
     */
    private static List<QnA_FrameworkQuestion__c> getFrameworkQuestions(Set<Id> quesIds, String language) {
        //Collection is read-only error with set
        Set<Id> setQuesIds = new Set<Id>(quesIds);
        List<QnA_FrameworkQuestion__c> listFrameworkQuestions = new List<QnA_FrameworkQuestion__c>();
        
      //  if(Schema.SObjectType.Checklist_Master__c.isAccessible()) {
            for(Checklist_Master__c checklist :[
                SELECT Id, QA_Question__c
                FROM Checklist_Master__c
                WHERE QA_Question__c != null
                    AND Include_as_Static_Checklist_Item__c = true
                    AND Language__c = :language
                //WITH SECURITY_ENFORCED
                LIMIT :BOS_Utility.getAvailableQueryLimit()
            ]) {
                setQuesIds.add(checklist.QA_Question__c);
          //  }
    
           // if(Schema.SObjectType.QnA_FrameworkQuestion__c.isAccessible() && Schema.SObjectType.QnA_FrameworkQuestion__c.fields.QuestionBody__c.isAccessible() && Schema.SObjectType.QnA_FrameworkQuestion__c.fields.Name.isAccessible() && Schema.SObjectType.QnA_FrameworkQuestion__c.fields.AnswerElement__c.isAccessible() && Schema.SObjectType.QA_Question_Option__c.fields.QA_Question__c.isAccessible() && Schema.SObjectType.QA_Question_Option__c.fields.Short_Value_of_Question_Options__c.isAccessible() && Schema.SObjectType.QA_Question_Option__c.fields.English_Version__c.isAccessible() && Schema.SObjectType.Checklist_Master__c.fields.QA_Question__c.isAccessible() && Schema.SObjectType.Checklist_Master__c.fields.Resource__c.isAccessible() && Schema.SObjectType.QnA_FrameworkQuestion__c.fields.ParentQuestion__c.isAccessible()) {
                listFrameworkQuestions = [
                    SELECT Id, QuestionBody__c, Name, AnswerElement__c,
                        (
                            SELECT Id, Short_Value_of_Question_Options__c, 
                                English_Version__c, English_Version__r.Short_Value_of_Question_Options__c
                            FROM QA_Question_Options__r LIMIT :BOS_Utility.getAvailableQueryLimit() 
                        ),
                        (
                            SELECT Id, Resource__c
                            FROM Checklist_Masters__r
                            WHERE Resource__c != null
                        ),
                        //For Towns Questions
                        (
                            SELECT Id
                            FROM Followup_Questions__r LIMIT :BOS_Utility.getAvailableQueryLimit() 
                        )
                    FROM QnA_FrameworkQuestion__c
                    WHERE Id IN :setQuesIds
                    //WITH SECURITY_ENFORCED
                    LIMIT :BOS_Utility.getAvailableQueryLimit()
                ];
          //  }
        }

        return listFrameworkQuestions;
    }

    private static List<Checklist_Master__c> getChecklistMasterByQuestion(Set<Id> quesIds, String language) {
        List<Checklist_Master__c> listChecklistMaster = new List<Checklist_Master__c>();
        
    //  if(Schema.SObjectType.Checklist_Master__c.isAccessible()) {
            listChecklistMaster = [
                SELECT Id, Needed_Response__c, Checklist_Template_Items__c,
                    QA_Question__c, QA_Question__r.AnswerElement__c, QA_Question__r.QuestionBody__c,
                    Checklist_Master_Parent__c, Checklist_Master_Parent__r.Checklist_Template_Items__c,
                    Checklist_Master_Parent__r.Check_child_records__c, Include_as_Static_Checklist_Item__c,
                    English_Version__c, English_Version__r.Needed_Response__c
                FROM Checklist_Master__c
                //Multilingual
                WHERE Language__c = :language
                    AND 
                    (
                        QA_Question__c IN :quesIds
                        OR 
                        Include_as_Static_Checklist_Item__c = true
                    )
                //WITH SECURITY_ENFORCED
                LIMIT :BOS_Utility.getAvailableQueryLimit()
            ];
        //}

        return listChecklistMaster;
   }

    private static List<Checklist_Master__c> getChecklistMasterByParent(Set<Id> setParentIds, String language) {
        List<Checklist_Master__c> listChecklistMaster = new List<Checklist_Master__c>();

       // if(Schema.SObjectType.Checklist_Master__c.isAccessible()){
            listChecklistMaster = [
                SELECT Id, Needed_Response__c, Checklist_Template_Items__c,
                    QA_Question__c, QA_Question__r.AnswerElement__c, QA_Question__r.QuestionBody__c,
                    Checklist_Master_Parent__c, Checklist_Master_Parent__r.Checklist_Template_Items__c,
                    Checklist_Master_Parent__r.Check_child_records__c, Include_as_Static_Checklist_Item__c,
                    English_Version__c, English_Version__r.Needed_Response__c
                FROM Checklist_Master__c
                WHERE Checklist_Master_Parent__c IN :setParentIds
                    AND Language__c = :language
                //WITH SECURITY_ENFORCED
                LIMIT :BOS_Utility.getAvailableQueryLimit()
            ];
      //  }

        return listChecklistMaster;
    }

    @TestVisible
    private static Map<String, Checklist_Mapping__mdt> getChecklistMapping() {
        Map<String, Checklist_Mapping__mdt> mappings = new Map<String, Checklist_Mapping__mdt>();
        
       // if(Schema.SObjectType.Checklist_Mapping__mdt.isAccessible()) {
            for(Checklist_Mapping__mdt checkMap : [
                SELECT Resource_Type__c, Object__c, Field__c, Additional_Fields__c, Group_By__c
                FROM Checklist_Mapping__mdt
                //WITH SECURITY_ENFORCED
                LIMIT :BOS_Utility.getAvailableQueryLimit()
            ]) {
                mappings.put(checkMap.Resource_Type__c, checkMap);
            }
     //   }

        return mappings;
    }

    /**
     * @created: 27/7/20 | CTBOS-3369
     * @desc: Get Template ChecklistItems
     *  Name = System.Label.Figure_out_license_template | Get TCI w/o checklistmaster
     */
    private static Map<Id, TemplateChecklistItems__c> getTemplateChecklistItems(Set<Id> checkListIds, String language) {
        Map<Id, TemplateChecklistItems__c> mapTemplateChecklistItems = new Map<Id, TemplateChecklistItems__c>();

      //  if(Schema.SObjectType.TemplateChecklistItems__c.isAccessible() && Schema.SObjectType.TemplateChecklistItems__c.fields.Category__c.isAccessible() && Schema.SObjectType.TemplateChecklistItems__c.fields.Display_Order__c.isAccessible() && Schema.SObjectType.TemplateChecklistItems__c.fields.Checklist_Item_Information__c.isAccessible() && Schema.SObjectType.TemplateChecklistItems__c.fields.Checklist_Item_Name__c.isAccessible() && Schema.SObjectType.TemplateChecklistItems__c.fields.Additional_Detail_Information__c.isAccessible() && Schema.SObjectType.TemplateChecklistItems__c.fields.Checklist_Category__c.isAccessible() && Schema.SObjectType.TemplateChecklistItems__c.fields.Language__c.isAccessible() && Schema.SObjectType.Checklist_Master__c.fields.Resource__c.isAccessible() && Schema.SObjectType.Checklist_Master__c.fields.Checklist_Template_Items__c.isAccessible()) {
            mapTemplateChecklistItems = new Map<Id, TemplateChecklistItems__c>([
                SELECT Id, Category__c, Display_Order__c, Checklist_Item_Information__c,
                    Checklist_Item_Name__c, Additional_Detail_Information__c, Checklist_Category__c,
                    (
                        SELECT Id, Resource__c
                        FROM BOS_Checklists__r
                        WHERE Resource__c != null
                    )
                FROM TemplateChecklistItems__c 
                WHERE ID IN: checkListIds
                OR
                    (
                        Checklist_Category__c = 'Licenses'
                        AND
                        Language__c = :language
                    )
                //WITH SECURITY_ENFORCED
                ORDER BY Display_Order__c ASC NULLS LAST
                LIMIT :BOS_Utility.getAvailableQueryLimit()
            ]);
        //}

        return mapTemplateChecklistItems;
    }

    //ii. Towns, iii. NAICS iv. Service
    @TestVisible
    private static TemplateChecklist getTemplateChecklist(ResourceWrapper res, TemplateChecklistItems__c templateItem) {
        TemplateChecklist templateChecklistWrapper = new TemplateChecklist(templateItem);
        
        //i. Set resource type as subsection id
        templateChecklistWrapper.subsectionId = res.checklistMap.Resource_Type__c;         
        
        for(sObject record :res.listRecords) {
            templateChecklistWrapper.dynamicData.add(DynamicData.getInstance(record));
        }

        return templateChecklistWrapper;
    }

    //v. Resources
    @TestVisible
    private static TemplateChecklist getChecklistResources(ResourceWrapper res, TemplateChecklistItems__c templateItem) {
        TemplateChecklist templateChecklistWrapper = new TemplateChecklist(templateItem);
        templateChecklistWrapper.subsectionId = res.checklistMap.Resource_Type__c; 
        Map<String, List<sObject>> mapGroupedListRecords = getMapResources(res.checklistMap.Group_By__c, res.listRecords);
                   
        for(String grouperFieldVal : mapGroupedListRecords.keySet()) {
            DynamicData dynamicDataref = new DynamicData(grouperFieldVal);
            
            for(sObject rd :mapGroupedListRecords.get(grouperFieldVal)) {
                dynamicDataref.resources.add(new Resource(rd));
            }
            templateChecklistWrapper.dynamicData.add(dynamicDataref);
        }

        return templateChecklistWrapper;
    }

    //For Licenses**
    enum ResponseType {
        VALUE_TYPE,
        FILTER_TYPE
    }

    /**
     * @created : 27/7/20 | CTBOOS-3369
     * @desc: Get records for resources based on Metadata details
     */
    @TestVisible
    private static List<sObject> getRecords(ResourceWrapper resource, String language) { 
        List<sObject> listRecords = new List<sObject>();
        List<sObject> listTempRecords = new List<sObject>();
        Map<String, String> mapResponses = getResponse(resource);
        Boolean hasFilterRecords = mapResponses.containsKey(String.valueOf(ResponseType.FILTER_TYPE));

        //i. If MDT/ ii.  Obj
        if(Schema.getGlobalDescribe().containsKey(resource.checklistMap.Object__c) && !mapResponses.isEmpty()) {
            String fields = getFields(resource.checklistMap);
            Boolean hasLanguageField = fields.containsIgnoreCase(TO_LABEL + System.Label.Open_Bracket + LANGUAGE_FIELD + System.Label.Close_Bracket);
            
            //SELECT
            String query = System.Label.Select + SPACE + fields + SPACE
                //FROM
                + System.Label.From + SPACE + resource.checklistMap.Object__c  + SPACE
                //WHERE
                + System.Label.WHERE_TEXT + SPACE + System.Label.Open_Bracket;
            
            //Has answer and language field
            if(mapResponses.containsKey(String.valueOf(ResponseType.VALUE_TYPE))) {
                query += resource.checklistMap.Field__c + SPACE + System.Label.In + SPACE + mapResponses.get(String.valueOf(ResponseType.VALUE_TYPE)) + SPACE;

                //LANGUAGE CLAUSE
                query += hasLanguageField
                    ? System.Label.And + SPACE + LANGUAGE_FIELD + SPACE + System.Label.EQUAL_TEXT + SPACE + '\''+ language + '\'' + SPACE
                    : SPACE;
            } else if(hasLanguageField) {
                query += hasLanguageField
                    ? LANGUAGE_FIELD + SPACE + System.Label.EQUAL_TEXT + SPACE + '\''+ language + '\'' + SPACE
                    : SPACE;   
            }
            
            query += System.Label.Close_Bracket + SPACE;

            // --------- Non-dynamic ---------
            //For Licenses (license details)
            query += hasFilterRecords && hasLanguageField
                ? 'OR' + SPACE + LANGUAGE_FIELD + SPACE +'= \'' + language + '\''
                : SPACE;            
            //For Resources Data (Order by)
            query += fields.contains('Display_Order__c')
                ? 'ORDER BY Display_Order__c ASC'
                : SPACE;
            
            listTempRecords = Database.query(query);
        } 

        //For licenses
        if(!listTempRecords.isEmpty() && hasFilterRecords) {
            Map<String, sObject> mapRecords = new Map<String, sObject>();
            List<String> listGivenResponses = mapResponses.get(String.valueOf(ResponseType.FILTER_TYPE)).split(System.Label.PIPELINE_SEPARATOR);
            String idResponse = mapResponses.get(String.valueOf(ResponseType.VALUE_TYPE));

            for(sObject record :listTempRecords) {
                String serviceTitle = record.get('English_Version__c') != null
                    ? String.valueOf(record.getSObject('English_Version__r').get('Service_Title__c') )
                    : String.valueOf(record.get('Service_Title__c'));

                if((String.isNotBlank(serviceTitle) && listGivenResponses.contains(serviceTitle))
                    || (String.isNotBlank(idResponse) && idResponse.contains(record.Id))
                ) {
                    //For category-based flow --> remove repeated licenses
                    String serviceDetails = record.get('Licenses_Details__c') != null
                        ? String.valueOf(record.get('Licenses_Details__c')).stripHtmlTags()
                        : serviceTitle;

                    mapRecords.put(serviceDetails, record);
                }           
            }

            listRecords = mapRecords.values();
        } else {
            listRecords = listTempRecords;
        }

        return listRecords;
    }

    /**
     * @created: 27/7/20 | CTBOS-3369
     * @desc: Get answer based on its format
     */
    private static Map<String, String> getResponse(ResourceWrapper resource) {
        Map<String, String> mapResponses = new Map<String, String>();
        
        for(String type :resource.mapTypeResponse.keySet()) { 
            String ans = String.isNotBlank(resource.mapTypeResponse.get(type)) ? String.escapeSingleQuotes(resource.mapTypeResponse.get(type)) : '';
            //switch doesnt work with Labels

            //i Category
            if(System.Label.Subsection_Id_NAICS_Code.equalsIgnoreCase(resource.checklistMap.Resource_Type__c)) {
                mapResponses.put(String.valueOf(ResponseType.VALUE_TYPE), '(\''+ ans.substringBetween('(', ')') + '\')');
            } 
            //ii. Search-Browse -> JSON
            else if(System.Label.Answer_Element_Search_Browse.equalsIgnoreCase(type)) {
                Set<String> setIds = new Set<String>();

                for (Object obj : (List<Object>) JSON.deserializeUntyped(ans)) {
                    Map<String, Object> mapAnswer = (Map<String, Object>)obj;

                    setIds.add((String) mapAnswer.get('id'));
                }

                if(!setIds.isEmpty()) {
                    mapResponses.put(String.valueOf(ResponseType.VALUE_TYPE), '(\'' + String.join(new List<String>(setIds), '\',\'') + '\')');   
                }
            }
            //iii Licenses: Multiselect
            else if(System.Label.Subsection_Id_Licenses.equalsIgnoreCase(resource.checklistMap.Resource_Type__c)) {
                mapResponses.put(String.valueOf(ResponseType.FILTER_TYPE), ans);
            }
            //iv. Single/MultiSelect
            else if(System.Label.Answer_Element_Search_Input.equalsIgnoreCase(type) 
                || System.Label.Lightning_Dual_List_Box.equalsIgnoreCase(type)
                || System.Label.Lightning_Input.equalsIgnoreCase(type) 
                || System.Label.Lightning_RadioGroup.equalsIgnoreCase(type)
                || System.Label.Lightning_Combobox.equalsIgnoreCase(type)
            ) {
                //FOR GROUP IDENTIFICATION | Do not replace pipe with label - gives extra \
                ans = (String.isNotBlank(ans) ? ans + PIPE : '') + 'No Group';//System.Label.No_Group;
                mapResponses.put(String.valueOf(ResponseType.VALUE_TYPE), '(\'' + String.join(ans.split(System.Label.PIPELINE_SEPARATOR), '\',\'') + '\')');
            }
        }

        return mapResponses; 
    }

    //Additional_Fields__c can contain child/parent fields
    private static String getFields(Checklist_Mapping__mdt checkMap) {
        Set<String> setFields = new Set<String>();
        
        for(Schema.SObjectField fld :Schema.getGlobalDescribe().get(checkMap.Object__c).getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult field = fld.getDescribe();

            //for multi-lingual  picklist values
            String fieldAPIName = Schema.DisplayType.Picklist.equals(field.getType()) 
                ? TO_LABEL + System.Label.Open_Bracket + field.getName() + System.Label.Close_Bracket 
                : field.getName();
            setFields.add(fieldAPIName);
        }

        if(String.isNotBlank(checkMap.Additional_Fields__c)) {
            setFields.addAll(checkMap.Additional_Fields__c.split(COMMA_SPLIT));
        }
        
        return String.join(new List<String>(setFields), COMMA_SPLIT);
    }

    /********************************************************************************************
        METHOD NAME    : getChecklistCategories
        DESCRIPTION    : Checklist_Category__c picklist values
        RETURN TYPE    : Map<String, String>
        PARAMETER      : Language
    ********************************************************************************************/
    private static Map<String, String> getChecklistCategories(String language) {
        Map<String, String> mapCategories = new Map<String, String>();

        for(Schema.PicklistEntry category: TemplateChecklistItems__c.Checklist_Category__c.getDescribe().getPicklistValues()) {
            mapCategories.put(category.getLabel(), category.getValue());
        }

        return mapCategories;
    }

    /********************************************************************************************
        METHOD NAME    : deleteCheckList
        DESCRIPTION    : This method will delete questionresponses and return an empty list of wrapper
        RETURN TYPE    : List<Section>
        PARAMETER      : Id questionnaireId
    ********************************************************************************************/
    @AuraEnabled
    public static Boolean deleteCheckList(Id questionnaireId) {
        Boolean checklistDeleted = false;
        try {
            if(questionnaireId != null) {
                List<QnA_QuestionResponse__c> questionresponses = [
                    SELECT Id, Question__c, Question__r.Required__c, Given_Response_Value__c, Questionnaire__c 
                    FROM QnA_QuestionResponse__c
                    WHERE Questionnaire__c =: questionnaireId 
                    WITH SECURITY_ENFORCED
                    LIMIT :BOS_Utility.getAvailableQueryLimit()
                ];
                
                //perform delete
                if(!questionresponses.isEmpty()) {
                    BOS_utility.deleteRecords(questionresponses);
                }
            
                BOS_utility.deleteRecords(new List<Questionnaire__c> { 
                    new Questionnaire__c(Id = questionnaireId)
                });
                checklistDeleted = true;
            }
            //Return true or false for deletion of records
            return checklistDeleted;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /********************************************************************************************
        CLASS NAME     : Checklist
        DESCRIPTION    : This class is a wrapper for List<Section>, Business Name , Questionnaire Name,CreatedDate
    ********************************************************************************************/
    public without sharing class Checklist {
        @AuraEnabled public String businessName {get;set;}
        @AuraEnabled public String questionnaireName {get;set;}
        @AuraEnabled public DateTime createdDate {get;set;}
        @AuraEnabled public List<Section> section {get;set;}
        @AuraEnabled public Boolean isGeneratedFirstTime {get;set;}

        Checklist(QnA_QuestionResponse__c questionResponse) {
            this.questionnaireName = questionResponse.Questionnaire__r.Name;
            this.createdDate = questionResponse.Questionnaire__r.CreatedDate;
            this.businessName = questionResponse.Questionnaire__r.Business_Name__c;
            this.isGeneratedFirstTime = true;
        }
    }

    /********************************************************************************************
        CLASS NAME     : Section
        DESCRIPTION    : This class is a wrapper for Category Name & List of TemplateChecklist(Wrapper Class)
    ********************************************************************************************/
    public without sharing class Section {
        @AuraEnabled public String sectionTitle {get;set;}
        @AuraEnabled public List<TemplateChecklist> subsection {get;set;}
        @AuraEnabled public String sectionIcon {get;set;}
    
        Section(String sectionTitle, String sectionIcon, List<TemplateChecklist> template,String questionnaireId,String language) {
            this.sectionTitle = sectionTitle;
            this.subsection = template;
            this.sectionIcon = sectionIcon.toLowerCase();

            String codeType = checkNAICSType(system.label.DEEPNAICSCodeCheckListValue, questionnaireId);

if(sectionTitle  == System.label.LicenseCategory){

    if(codeType!=null && codeType.contains(system.label.DEEPNAICSCodeCheckListValue))
    {
  TemplateChecklistItems__c item=       getNaicsRelatedTemplate(system.label.DEEPNAICSCodeCheckListValue,language);
if(item!=null){
     TemplateChecklist titem = new TemplateChecklist();
    titem.subHeading = item.Checklist_Item_Name__c;
    titem.rteText = item.Additional_Detail_Information__c;
    //titem.subsectionId = 'Licenses';
    titem.subsectionId = item.id;
    titem.dynamicData = new List<dynamicData>();
     this.subsection.add(titem);
    }
}
}

if(sectionTitle == System.label.BusinessRegistrationCategory){

    if(codeType!=null && codeType.contains(system.label.DRSManufacturingNAICSCodeCheckListValue))
    {
  TemplateChecklistItems__c item=       getNaicsRelatedTemplate(system.label.DRSManufacturingNAICSCodeCheckListValue,language);
if(item!=null){
     TemplateChecklist titem = new TemplateChecklist();
    titem.subHeading = item.Checklist_Item_Name__c;
    titem.rteText = item.Additional_Detail_Information__c;
    titem.subsectionId = item.id;
    titem.dynamicData = new List<dynamicData>();
   this.subsection.add(titem);
 }
}
else if(codeType!=null && codeType.trim().equalsIgnoreCase(system.label.DRSCostructionNAICSCodeCheckListValue.trim()))
{
TemplateChecklistItems__c item=       getNaicsRelatedTemplate(system.label.DRSCostructionNAICSCodeCheckListValue.trim(),language);

if(item!=null){
       TemplateChecklist titem = new TemplateChecklist();
    titem.subHeading = item.Checklist_Item_Name__c;
    titem.rteText = item.Additional_Detail_Information__c;
    titem.subsectionId = item.id;
    titem.dynamicData = new List<dynamicData>();
   this.subsection.add(titem);
}
}


}

        }

    }

    /********************************************************************************************
        CLASS NAME     : TemplateChecklist
        DESCRIPTION    : This class is a wrapper for Static text from Additional information,Checklist Title,
                        a subsectionId to identify each template, dynamic data for each template.
    ********************************************************************************************/
    public without sharing class TemplateChecklist {
        @AuraEnabled public String rteText {get;set;} // additional information
        @AuraEnabled public String subHeading {get;set;} // checklist title
        @AuraEnabled public String subsectionId {get;set;}
        @AuraEnabled public List<dynamicData> dynamicData {get;set;}
        @AuraEnabled public Boolean isComplete {get;set;}
        public TemplateChecklist(TemplateChecklistItems__c template) {
            this.subHeading = template.Checklist_Item_Name__c.unescapeHtml4();
            this.rteText = template.Additional_Detail_Information__c;
            this.dynamicData = new List<dynamicData>();
            this.subsectionId = template.Id;
            this.isComplete = false;
        }
        public TemplateChecklist(){}
        public TemplateChecklist(List<dynamicData> dynamicData, TemplateChecklistItems__c template) {
            this.dynamicData = dynamicData;
            this.rteText = template.Additional_Detail_Information__c;
            this.subHeading = template.Checklist_Item_Name__c;
            this.isComplete = false;
        }
    }

    //To-Do | Generic
    @TestVisible
    private static DynamicData getInstance(sObject record) {
        String obj = record.Id.getSObjectType().getDescribe().getName();
        DynamicData dynamicData = new DynamicData(obj);
        
        if('Municipality_Information__mdt'.equalsIgnoreCase(obj)) {
            dynamicData = new DynamicData((Municipality_Information__mdt) record);
        } else if('Category__c'.equalsIgnoreCase(obj)) {
            dynamicData = new DynamicData((Category__c) record);
        } else if('Service__c'.equalsIgnoreCase(obj)) {               
            dynamicData = new DynamicData((Service__c) record);
        }

        return dynamicData;
    }
    
    /********************************************************************************************
        CLASS NAME     : dynamicData
        DESCRIPTION    : This class is a wrapper for dynamic data for each template.
    ********************************************************************************************/
    public without sharing class DynamicData {
        @AuraEnabled public String naicsCode {get;set;}
        @AuraEnabled public String naicsSubcode {get;set;}
        @AuraEnabled public String addressTitle {get;set;}
        @AuraEnabled public String address {get;set;}
        @AuraEnabled public String state {get;set;}
        @AuraEnabled public String city {get;set;}
        @AuraEnabled public String zip {get;set;}
        @AuraEnabled public String phoneNumber {get;set;}
        @AuraEnabled public String website {get;set;}
        @AuraEnabled public Boolean external {get;set;}
        @AuraEnabled public String resourceTitle {get;set;}
        @AuraEnabled public List<Resource> resources {get;set;}
        @AuraEnabled public String licenseDetails {get;set;}

        public DynamicData(Category__c subcategory) {
            this.naicsSubcode = subcategory.Title__c + '(' + subcategory.Code__c + ')';
            if(subcategory.Parent_Category__r != null) {
                this.naicsCode = subcategory.Parent_Category__r.Parent_Category__r.Parent_Category__r.Title__c 
                    + '(' + subcategory.Parent_Category__r.Parent_Category__r.Parent_Category__r.Code__c + ')';
            }
        }

        public DynamicData(String resourceTitle) {
            resources = new List<Resource>();
            this.resourceTitle = resourceTitle;
        }

        //CTBOS-3804 | Multi-lingual support | Picklist is translated and mapped
        public DynamicData(Municipality_Information__mdt townAddress) {
            this.addressTitle = townAddress.City_Town_2__c + SPACE + townAddress.City_Town__c;
            this.address = townAddress.StreetAddress__c;
            this.state = townAddress.State__c;
            this.zip = townAddress.Zip_Code__c;
            this.phoneNumber = townAddress.Phone_Number__c;
            this.website = townAddress.Municipality_URL__c;
            this.external = townAddress.External_or_Internal_URL__c;
        }

        //CTBOS-3369 | Escape HTML tags - Specifically for licenses
        public DynamicData(Service__c service) {
            this.licenseDetails = service != null && String.isNotBlank(service.Licenses_Details__c) ? service.Licenses_Details__c : '';
        }
    }

    /********************************************************************************************
    CLASS NAME     : Resource
    DESCRIPTION    : This class is a wrapper for Resource Records
    ********************************************************************************************/
    public without sharing class Resource {
        @AuraEnabled public String resourceLinkLabel {get;set;}
        @AuraEnabled public String resourceURL {get;set;}
        @AuraEnabled public String resourceNumber {get;set;}
        @AuraEnabled public String resourceDescription {get;set;}
        @AuraEnabled public Boolean externalURL {get;set;}

        public Resource(sObject resource) {
            Resources_Data__mdt resourceData = (Resources_Data__mdt) resource;
            
            this.resourceDescription = resourceData.Description__c;
            this.resourceURL = resourceData.Link_to_Resource__c;
            this.resourceLinkLabel = resourceData.Title_of_Resource__c;
            this.resourceNumber = resourceData.Phone__c;
            this.externalURL = resourceData.External_or_Internal_URL__c;
        }

    }

    public without sharing class ServiceObject {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
    }

    /**
     * @created: 27/07/2020 | CTBOS-3369
     * @desc: Wrapper for different compliance & regulatory objects - License, Groups etc. 
     */
    @TestVisible
    private without sharing class ResourceWrapper {
        private Checklist_Mapping__mdt checklistMap;
        private Map<String, String> mapTypeResponse;
        @TestVisible private List<sObject> listRecords;
            
        @TestVisible
        private ResourceWrapper(Checklist_Mapping__mdt checklistMap, String givenResponse, String ansElement) {
            this.checklistMap = checklistMap;
            this.mapTypeResponse = new Map<String, String>();
            this.mapTypeResponse.put(ansElement, givenResponse);
            this.listRecords = new List<sObject>();
        }
    }




    @AuraEnabled
    public static String createnewClonedApplication(String appID){
        String detail = null;
        try{
           
            if(String.isNotBlank(appID) && String.isNotEmpty(appID)){
                Questionnaire__c app  = [Select id,Contact__c,Status__c,Category__c,Language__c,Total_no_of_Sections__c,Completed_Section_Count__c,Business_Name__c from  Questionnaire__c where id =:appID LIMIT 1];
                Questionnaire__c capp  = app.clone(false, false, false, false);
                
            capp.Status__c = 'In Progress';
                capp.Total_no_of_Sections__c =0;
             capp.Completed_Section_Count__c =0;
             capp.ParentQuestionnaire__c=appID;
             capp.isCloneChecked__c=true;
                insert capp;
            System.debug('app'+app);
            System.debug('capp'+capp);
            
           
detail= capp.id;

              System.debug('app.id'+app.id+' capp.id'+capp.id);
              addClonedResponses(app.id, capp.id);
            
            }       
        }catch(Exception e){
                 System.debug('e'+e.getMessage());
            return null;
            
        }
        return detail;
        
        
    }
 private static void addClonedResponses(String appID,String newID)   {

    List<QnA_QuestionResponse__c> responses = [Select id,Question_Body__c,Question__c,Given_Response__c,Given_Response_Value__c,Other_Given_Response__c
    ,Other_Question_Body__c,Other_Short_value__c,Questionnaire__c from QnA_QuestionResponse__c where Questionnaire__c=:appID];
List<QnA_QuestionResponse__c> newResponses = new List<QnA_QuestionResponse__c>();
    for(QnA_QuestionResponse__c response :responses){
        QnA_QuestionResponse__c nResponse = response.clone(false,false,false,false);
        nResponse.Questionnaire__c = newID;
    newResponses.add(nResponse);
    }

    if(!newResponses.isEmpty()){
        insert newResponses;
    }
 }

private static String checkNAICSType(String type,String parentID){

    String isGivenType = null;
if(String.isNotEmpty(parentID) && String.isNotBlank(parentID))
{
    List<Questionnaire__c> questonare = [Select id ,Category__c,Category__r.NAICS_Code_Categories__c from Questionnaire__c where id = :parentID Limit 1];
    if(questonare!=null && !questonare.isEmpty()){
         isGivenType =questonare[0].Category__r.NAICS_Code_Categories__c;
      
    }
}
return isGivenType;
}
public static TemplateChecklistItems__c getNaicsRelatedTemplate(String type, String language){

List<TemplateChecklistItems__c> temp = [Select id,Checklist_Item_Name__c, Additional_Detail_Information__c from TemplateChecklistItems__c
where Language__c = :language and NAICS_Code_Category__c = :type];
if(temp!=null && !temp.isEmpty()){
    return temp[0];
}
return null;
}


@AuraEnabled 
public static void updateJson(String questionaireID,String Json){
    update (new Questionnaire__c(
            id = questionaireID, 
            
            JSON_Response__c = Json
        ));
}

}