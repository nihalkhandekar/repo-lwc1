public class ProductConsumedTriggerHandler {
    public static void productConsumedUnitPrice(List<ProductConsumed> pc) {
        Set<Id> productItemIds = new Set<Id>();
        
        for (ProductConsumed prodConsumed : pc) {
            if (prodConsumed.ProductItemId != null) {
                productItemIds.add(prodConsumed.ProductItemId);
            }
        }
        
        List<ProductItem> productItems = [SELECT Id, Product2.Price__c FROM ProductItem WHERE Id IN :productItemIds];
        
        if (!productItems.isEmpty()) {        
            Map<Id, Decimal> productItemPriceMap = new Map<Id, Decimal>();
            
            for (ProductItem item : productItems) {
                productItemPriceMap.put(item.Id, item.Product2.Price__c);
            }
            
            for (ProductConsumed prodConsumed : pc) {
                if (productItemPriceMap.containsKey(prodConsumed.ProductItemId)) {
                    prodConsumed.UnitPrice = productItemPriceMap.get(prodConsumed.ProductItemId);
                }
            }
        }
    }
    public static void PopulateSubtotalPrice(List<ProductConsumed> newProducts){
        Set<Id> workOrderIds = new Set<Id>();
        
        for(ProductConsumed prodConsumed : newProducts){
            if(prodConsumed.WorkOrderId !=  null){
                workOrderIds.add(prodConsumed.WorkOrderId);
            } 
        }
        
        if(!workOrderIds.isEmpty()){
            Map<Id, Decimal> workOrderTotalMap = new Map<Id, Decimal>();
            List<ProductConsumed> prodConsumedList = [SELECT WorkOrderId, Subtotal 
                                                      FROM ProductConsumed 
                                                      WHERE WorkOrderId IN :workOrderIds];
            for(ProductConsumed prodConsumed : prodConsumedList){
                if(prodConsumed.Subtotal != null){
                    if(!workOrderTotalMap.containsKey(prodConsumed.WorkOrderId)){
                        workOrderTotalMap.put(prodConsumed.WorkOrderId, 0);
                    }
                    workOrderTotalMap.put(prodConsumed.WorkOrderId, workOrderTotalMap.get(prodConsumed.WorkOrderId) + prodConsumed.Subtotal);
                }
            }
            
            List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
            
            for(Id workOrderId : workOrderIds){
                if(workOrderTotalMap.containsKey(workOrderId)){
                    WorkOrder wrkOrd = new WorkOrder(Id = workOrderId, Grant_SubTotal__c = workOrderTotalMap.get(workOrderId));
                    workOrdersToUpdate.add(wrkOrd);
                }
            }
            
            if(!workOrdersToUpdate.isEmpty()){
                update workOrdersToUpdate;
            }
        }
    }
    public static void updateAdditionalItemConsumedQuantity(List<ProductConsumed> prodCons) {
        
        Set<Id> productItemIds = new Set<Id>();  
        Map<Id, Decimal> productAdditionlItemConsumedQtyMap = new Map<Id, Decimal>();
        list<ProductItem> prodConsumedAdditionalItemQtyToUpdate = new list<ProductItem>();
        
        for (ProductConsumed prodConsumed : prodCons) {
            if (prodConsumed.QuantityConsumed != null && prodConsumed.UnitPrice == 0.00) {
                productItemIds.add(prodConsumed.ProductItemId);
                system.debug('productItemIds@@@'+productItemIds);
            }
        }  
        
        List<ProductItem> productItems = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Id IN :productItemIds];
        
        if(!productItems.isEmpty()){
            for(ProductItem item : productItems){
                item.QuantityOnHand = 100;
                system.debug('item.QuantityOnHand@@@'+item.QuantityOnHand);
                prodConsumedAdditionalItemQtyToUpdate.add(item);            
            }
            if(prodConsumedAdditionalItemQtyToUpdate.size() > 0){
                update prodConsumedAdditionalItemQtyToUpdate;
            }
        }
    }
}