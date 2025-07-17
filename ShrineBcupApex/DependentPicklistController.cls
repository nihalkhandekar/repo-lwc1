public with sharing class DependentPicklistController {
    @AuraEnabled(cacheable=true)
    public static String fetchDependentPicklistValues(){
        Map<String,List<Map<String,List<String>>>> MapOfDependentPicklsit = new Map<String,List<Map<String,List<String>>>>();
        for(AggregateResult ag : [select Type, Rating, Industry from Account where Type!=null and Rating!=null and Industry!=null Group By Type, Rating, Industry]){
            Map<String,List<String>> mapOfRatingAndIndustry = new Map<String,List<String>>();
            if(mapOfRatingAndIndustry.containsKey(String.valueOf(ag.get('Rating')))){
                mapOfRatingAndIndustry.get(String.valueOf(ag.get('Rating'))).add(String.valueOf(ag.get('Industry')));
            }else{
                mapOfRatingAndIndustry.put(String.valueOf(ag.get('Rating')),new List<String>{String.valueOf(ag.get('Industry'))});
            }
            if(MapOfDependentPicklsit.containsKey(String.valueOf(ag.get('Type')))){
                MapOfDependentPicklsit.get(String.valueOf(ag.get('Type'))).add(mapOfRatingAndIndustry);
            }else{
                MapOfDependentPicklsit.put(String.valueOf(ag.get('Type')),new List<Map<String,List<String>>>{mapOfRatingAndIndustry});
            }
        }
        return JSON.serialize(MapOfDependentPicklsit);
    }
}