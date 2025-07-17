public class BackOfficeRejectionComments1 {
    
    @InvocableMethod(label='Rejection Comments')
        public static List<FlowOutputs> invokeLocalMethod(List<FlowInputs> rejectionComments){
            
        List<FlowOutputs> output = new List<FlowOutputs>();
        FlowOutputs o = new FlowOutputs();

        String inputList = JSON.serializePretty(rejectionComments, true);
   		List<Object> result = (List<Object>)JSON.deserializeUntyped(inputList);
        Map<String,Object> newMapp = new Map<String,Object>();
        List<String> commentValues = new List<String>();
        List<String> newList = new List<String>();
            
        for(Object obj : result) { 
            Map<String,Object> map1 = (Map<String,Object>)obj; 
            if((String)map1.get('RejectionComments1') != null && (String)map1.get('RejectionComments1') != ''){
                newMapp.put('RejectionComments1', (String)map1.get('RejectionComments1'));
                newList.add((String)map1.get('RejectionComments1'));
            }
            if((String)map1.get('RejectionComments2') != null && (String)map1.get('RejectionComments2') != ''){
                newMapp.put('RejectionComments2', (String)map1.get('RejectionComments2'));
                newList.add((String)map1.get('RejectionComments2'));
            }
            if((String)map1.get('RejectionComments3') != null && (String)map1.get('RejectionComments3') != ''){
                newMapp.put('RejectionComments3', (String)map1.get('RejectionComments3'));
                newList.add((String)map1.get('RejectionComments3'));
            }
            if((String)map1.get('RejectionComments4') != null && (String)map1.get('RejectionComments4') != ''){
                newMapp.put('RejectionComments4', (String)map1.get('RejectionComments4'));
                newList.add((String)map1.get('RejectionComments4'));
            }
            if((String)map1.get('RejectionComments5') != null && (String)map1.get('RejectionComments5') != ''){
                newMapp.put('RejectionComments5', (String)map1.get('RejectionComments5'));
                newList.add((String)map1.get('RejectionComments5'));
            }
            if((String)map1.get('RejectionComments6') != null && (String)map1.get('RejectionComments6') != ''){
                newMapp.put('RejectionComments6', (String)map1.get('RejectionComments6'));
                newList.add((String)map1.get('RejectionComments6'));
            }
            if((String)map1.get('RejectionComments7') != null && (String)map1.get('RejectionComments7') != ''){
                newMapp.put('RejectionComments7', (String)map1.get('RejectionComments7'));
                newList.add((String)map1.get('RejectionComments7'));
            } 
		}
        if(!newMapp.isEmpty()){
            String str = String.valueof(newMapp.values());
            String str2 = str.replaceAll('\\(', '').replaceAll('\\)', '');

            List<String> lstString = str2.split(',');
        }
            
        String allStrings = '';
    
        if(newList.size() > 0){
            for(String s: newList){
                
                if(newMapp.isEmpty()){
                 allStrings = '';                    
                 
                }
                else if((!newMapp.isEmpty()) && (allStrings == null || String.isBlank(allStrings))){
                    
                allStrings = '•' + ' ' + s + '\n';
       
                }
                    
                else if((!newMapp.isEmpty()) && ((allStrings != null) || (!String.isBlank(allStrings)))){
		
                   allStrings = allStrings + '•' + ' ' + s + '\n';
                }
            }
        }

        if(allStrings != ''){
            allStrings = allStrings.substringBeforeLast('\n');
        }
            
        o.rejectionOutput = allStrings;

        if(!newMapp.isEmpty()){
            o.rejectedPopulated = 'Reject';
                
        }
        else{
            o.rejectedPopulated = 'Approve';
        }
        output.add(o);
        
        return output;
    }

    public class FlowInputs{                
        @InvocableVariable
        public String RejectionComments1;
        @InvocableVariable
        public String RejectionComments2;
        @InvocableVariable
        public String RejectionComments3;
        @InvocableVariable
        public String RejectionComments4;              
        @InvocableVariable
        public String RejectionComments5;
        @InvocableVariable
        public String RejectionComments6;              
        @InvocableVariable
        public String RejectionComments7;
        @InvocableVariable
        public String DomesticAgentConfirmationComponent;         
    }
    
    public class FlowOutputs{
        @InvocableVariable
        public String rejectionOutput;              
        @InvocableVariable
	    public String rejectedPopulated;        
    }
}