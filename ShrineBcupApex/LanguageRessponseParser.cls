public with sharing class LanguageRessponseParser {
public Translations data;
    
   public class Translations{
      public  List<Translation> translations;
        public List<Translation> getTranslation(){
           return this.translations;
        }
        
    }
   public class Translation{
      public  String translatedText;
        
    }
    public static LanguageRessponseParser parse(String json) {
        return (LanguageRessponseParser) System.JSON.deserialize(json, LanguageRessponseParser.class);
    }

    public static List<String> getTranslations(String response) {
        List<String> listTranslations = new List<String>();
        LanguageRessponseParser lannguageResponse = (LanguageRessponseParser) JSON.deserialize(response, LanguageRessponseParser.class);

        for(LanguageRessponseParser.Translation translation :lannguageResponse.data.translations) {
            listTranslations.add(translation.translatedText);
        }

        return listTranslations;
    }
}