/**
 * @name        : CTBOT_ChatWindowCtrl
 * @description : Handles all translations controls, calls SDL or Google Translation services based on language pair availability
 * @depends     : SDL_API_Configuration__mdt
 * @author      : Slalom
 * @createddate : 11/2019
 * @Modification log:
    * Slalom - 10/2020 - CTBOT project
    * Slalom - 11/2020 - Add update function to populate origination URL
    TO-DO: 
    Connect service ctrl for SDL translations - phase 2

 **/
global class CTBOT_ChatWindowCtrl {
    /**
     * @name        : getTranslationForChatWindow
     * @description : Handles custom chat input translation to English for the chatbot
     * @depends     : CTBOT_ChatWindow
     * @author      : Slalom
     * @createddate : 11/2019
     **/

        @RemoteAction
        global static void setTranscriptOrigination(String originURL, String chatKey){
            if(!String.isBlank(originURL) && !String.isBlank(chatKey)){
                LiveChatTranscript transcript = [SELECT Id, Origination__c FROM LiveChatTranscript WHERE ChatKey = :chatKey];
                transcript.Origination__c = originURL;
				update transcript;
            }
        }

        /*@RemoteAction
        global static String getTranslationForChatWindow(String sourceLanguage, String targetLanguage, String textToTranslate){
            String translation = translate(sourceLanguage, targetLanguage, textToTranslate);
            return translation;
        }
    
        @AuraEnabled
        public static String getTranslationForComponent(String sourceLanguage, String targetLanguage, String textToTranslate){
            String translation = translate(sourceLanguage, targetLanguage, textToTranslate);
            return translation;
        }
    
        public static String translate(String sourceLanguage, String targetLanguage, String textToTranslate){
            
            system.debug('Language src code: ' + sourceLanguage);
            system.debug('Language target code: ' + targetLanguage);
            system.debug('Text to translate: ' + textToTranslate);
            
            String translationForChat = '';
            try {
                
                //translationForChat = slalom_SDLTranslationService.translateText(langSrcCode, targetLanguage, textToTranslate);

            } catch (Exception ex) {
                throw ex;
            }
    
            system.debug('Translation: ' + translationForChat);
            return translationForChat;
        }
        
    
        private static Map<String, String> getLanguageAvailabilityMap(String src){
            Map<String, String> langMap = new Map<String, String>();
            //Get the ISO language code needed for API
            String langCode = getLanguageCode(src);
    
            //Map language code to API vendor
            Map<String, String> languageVendorMap = new Map<String, String>();

            //Return the language vendor and language code for API
            langMap.put(langCode, languageVendorMap.get(langCode));
            return langMap;
    
        }
    
        private static String getLanguageCode(String sourceLanguage){
            Map<String, String> languageCodeMap = new Map<String, String>();
            languageCodeMap = CTBOT_GlobalLanguagePairs.getGlobalLanguagePairs();
    
            return languageCodeMap.get(sourceLanguage);
            
        }
    
        @RemoteAction
        public static Map<String, String> getLanguagePairs(){
            return CTBOT_GlobalLanguagePairs.getGlobalLanguagePairs();
        }
*/
    }