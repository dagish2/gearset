public class ScheduleBatchToUpdateMarketOnAccount implements Schedulable{
    Integer batchSize = 80;
    public ScheduleBatchToUpdateMarketOnAccount(){
        this.batchSize = BatchToUpdateMarketHelper.getBatchSize(BatchToUpdateMarketHelper.getUpdateMarketBatchMetadata('UpdateMarketRetrialBatchMetadata'), 'Account');        
    }
    public void execute(SchedulableContext SC) {       
        Database.executeBatch(new RetrialBatchToUpdateMarket('Account'),  batchSize);
    } 
}