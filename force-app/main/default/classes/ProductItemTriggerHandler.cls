public class ProductItemTriggerHandler {
    public static void handleTrigger(List<ProductItem> newProductItems, Map<Id, ProductItem> oldProductItemMap) {
        Set<Id> parentLocationIds = new Set<Id>();
        Set<Id> childLocationIds = new Set<Id>();
        
        // Get parent and child location ids
        List<Schema.Location> parentLocations = [SELECT Id FROM Location];
        for(ProductItem item : newProductItems) {
            if(item.LocationId != null){
                childLocationIds.add(item.LocationId);
            }
        }
        
        // Query parent location IDs outside of the loop
        Map<Id, Id> locationParentMap = new Map<Id, Id>();
        for (Schema.Location loc : [SELECT Id, ParentLocationId FROM Location WHERE Id IN :childLocationIds]) {
            if (loc.ParentLocationId != null) {
                locationParentMap.put(loc.Id, loc.ParentLocationId);
                parentLocationIds.add(loc.ParentLocationId);
            }
        }
        
        // Sync product items
        if(!parentLocationIds.isEmpty() && !childLocationIds.isEmpty()) {
            syncProductItems(parentLocationIds, childLocationIds);
        }
    }
    
    private static void syncProductItems(Set<Id> parentLocationIds, Set<Id> childLocationIds) {
        List<ProductItem> productItemsToUpdate = new List<ProductItem>();
        
        // Query product items for parent and child locations
        List<ProductItem> parentProductItems = [SELECT Id, LocationId, QuantityOnHand FROM ProductItem WHERE LocationId IN :parentLocationIds];
        List<ProductItem> childProductItems = [SELECT Id, LocationId, QuantityOnHand FROM ProductItem WHERE LocationId IN :childLocationIds];
        
        // Map to store product items by location ID
        Map<Id, ProductItem> parentProductItemMap = new Map<Id, ProductItem>();
        Map<Id, Decimal> childQuantitiesByLocation = new Map<Id, Decimal>();
        
        // Populate maps with product items
        for(ProductItem item : parentProductItems) {
            parentProductItemMap.put(item.LocationId, item);
        }
        for(ProductItem item : childProductItems) {
            if (childQuantitiesByLocation.containsKey(item.LocationId)) {
                childQuantitiesByLocation.put(item.LocationId, childQuantitiesByLocation.get(item.LocationId) + item.QuantityOnHand);
            } else {
                childQuantitiesByLocation.put(item.LocationId, item.QuantityOnHand);
            }
        }
        
        // Update parent product items based on child quantities
        for(Id parentId : parentLocationIds) {
            ProductItem parentItem = parentProductItemMap.get(parentId);
            Decimal childQuantity = childQuantitiesByLocation.get(parentId);
            if(parentItem != null && childQuantity != null) {
                parentItem.QuantityOnHand += childQuantity;
                productItemsToUpdate.add(parentItem);
            }
        }
        
        // Update product items
        if(!productItemsToUpdate.isEmpty()) {
            update productItemsToUpdate;
        }
    }
    
}