public class OppSelectedWrapTask {
Public Opportunity opp {get; set;}
public List<Opportunity> OppList {get; set;}
public List<WrapOpp> WrapList {get; set;}
public Set<Id> OppId {get; set;}
public Integer RowIndex1 {get; set;}
public Integer RowIndex2 {get; set;}
public List<Task> TaskList {get; set;}
public String userId {get; set;}
public ApexPages.StandardSetController MyController;
 
       public OppSelectedWrapTask(ApexPages.StandardSetController Controller) {
       this.MyController = Controller;
       WrapList = new List<WrapOpp> ();
       OppList = new List<Opportunity> ();
       TaskList = new List<Task> ();
       OppId = new Set<Id> ();
       userId = UserInfo.getUserId();

       
       for(Opportunity opp : (list<Opportunity>)MyController.getSelected()){
       OppId.add(opp.id);
       }
       for(Opportunity op : [select id, name, Type, StageName, LeadSource, ExpectedRevenue from Opportunity where id =: OppId]){
       WrapList.add(new WrapOpp(op)); 
       system.debug(WrapList);
       }
    }
    
Public class WrapOpp{
public Opportunity oppo {get; set;}
public boolean b {get; set;}
     public WrapOpp(Opportunity oppor){
     oppo = oppor;
     b= false;
     }
 } 
     public void selectRecord() {        
        for(WrapOpp wo: WrapList) {
        if(wo.b == true){
        OppList.add(wo.oppo);
          }
        }
    }
    public void Remove1(){
    WrapList.remove(RowIndex1-1);
    }
    public void Remove2(){
    OppList.remove(RowIndex2-1);
    }
    public void taskInsert(){
    for(Opportunity o : OppList) {
    Task t = new Task();
    t.OwnerId = userId;
    t.Subject = 'Game On';
    t.Status = 'open';
    t.Priority = 'normal';
    t.WhatId = o.Id;
    TaskList.add(t);
   }
   insert TaskList;
  }  
}