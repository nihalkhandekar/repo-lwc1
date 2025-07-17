@isTest
private class ctds_flowStage_Test {
    
   @isTest static void UnitTestMethod1(){
      
      ctds_flowStage[] blankArray = new ctds_flowStage[]{};
      ctds_flowStage stage = new ctds_flowStage('','',true,1,'',false,'','',blankArray);
      ctds_flowStage stage1 = new ctds_flowStage('','',true,1,'',false,'','',blankArray);
       
      Test.startTest();
       
      stage.compareTo(stage1);
      System.assertEquals(0, stage.compareTo(stage1));
       
      Test.stopTest(); 
     }
    
    @isTest static void UnitTestMethod2(){
        
      ctds_flowStage[] blankArray = new ctds_flowStage[]{};
      ctds_flowStage stage = new ctds_flowStage('','',true,1,'',false,'','',blankArray);
      ctds_flowStage stage2 = new ctds_flowStage('','',true,2,'',false,'','',blankArray);
      
      Test.startTest();
        
      stage.compareTo(stage2);
      System.assertEquals(-1, stage.compareTo(stage2));  
        
      Test.stopTest(); 
   
    }
    
     @isTest static void UnitTestMethod3(){
         
      ctds_flowStage[] blankArray = new ctds_flowStage[]{};
      ctds_flowStage stage = new ctds_flowStage('','',true,1,'',false,'','',blankArray);
      ctds_flowStage stage3 = new ctds_flowStage('','',true,0,'',false,'','',blankArray);
      
       Test.startTest();
         
       stage.compareTo(stage3);
       System.assertEquals(1, stage.compareTo(stage3)); 
         
       Test.stopTest();
         
     }
}