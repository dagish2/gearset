public class ScheduleBatchToUpdateMarketOnLead implements Schedulable{
    Integer batchSize = 700;
    public ScheduleBatchToUpdateMarketOnLead(){
        this.batchSize = BatchToUpdateMarketHelper.getBatchSize(BatchToUpdateMarketHelper.getUpdateMarketBatchMetadata('UpdateMarketRetrialBatchMetadata'), 'Lead');        
    }
    public void execute(SchedulableContext SC) {       
        Database.executeBatch(new RetrialBatchToUpdateMarket('Lead'),  batchSize);
    }    
}