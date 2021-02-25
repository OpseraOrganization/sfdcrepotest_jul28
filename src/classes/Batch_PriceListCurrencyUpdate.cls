/****************************************
	 * Name : Batch_PriceListCurrencyUpdate
	 * Author : Accenture
	 * Description : This class is for updating list price values for price list items
	 *		for each currency exchange rate updated in PMDI mapping
	 * ReqNo : 4571(D-8396), 5025
	****************************************/
global class Batch_PriceListCurrencyUpdate implements Database.Batchable<sObject>,Database.Stateful {
		 
	String currencyCode, portfolio;
	Decimal conversionRate;
	List<NokiaCPQ_PMDI_Parameter__c> parameterEntry;	
	List<String> currencyList = new List<String>();
	List<String> portfolioList = new List<String>();
	Map<String,List<String>> currPortfolioMap = new Map<String,List<String>>();
	Map<String,Decimal> conversionRateMap = new Map<String,Decimal>();
	
	/****************************************
		 * Name : Batch_PriceListCurrencyUpdate
		 * Description : constructor for assigning paramter entry from process builder
		 *		to batch class
		 * Parameters: List of Nokia PMDI paramter entry
		 * Returns : NA
	 *****************************************/
	public Batch_PriceListCurrencyUpdate(List<NokiaCPQ_PMDI_Parameter__c> paramterEntry)
	{
		this.parameterEntry = paramterEntry;
	}
   
	/****************************************
		 * Name : start
		 * Description : method which retrieves price list item entries which 
		 *	has portfolio and currency same as paramter entry
		 * Parameters: Database.BatchableContext
		 * Returns : Database.QueryLocator
	 *****************************************/
	global Database.QueryLocator start(Database.BatchableContext BC)
		{	 
			System.debug('Parameter entry: '+parameterEntry);
			String sourceCurr = '';
			for(NokiaCPQ_PMDI_Parameter__c param : parameterEntry)
			{
	if(param.NokiaCPQ_ParaType__c.equalsIgnoreCase('FX_RATE_EUR'))
	 	sourceCurr = 'EUR';
	if(param.NokiaCPQ_ParaType__c.equalsIgnoreCase('FX_RATE_USD'))
	 	sourceCurr = 'USD';
	if(currPortfolioMap.containsKey(sourceCurr))
		currPortfolioMap.get(sourceCurr).add(param.NokiaCPQ_ParaFrom__c);
	else
		currPortfolioMap.put(sourceCurr,new List<String>{param.NokiaCPQ_ParaFrom__c});
	
	//Add all portfolio's to portfolio list
	if(!(portfolioList.contains(param.NokiaCPQ_ParaFrom__c)))
		portfolioList.add(param.NokiaCPQ_ParaFrom__c);
	
	//Add conversion rate along with currency and portfolio
	conversionRateMap.put(sourceCurr+param.NokiaCPQ_ParaFrom__c, Decimal.valueOf(param.NokiaCPQ_ParaTo__c));
			}
			currencyList.addAll(currPortfolioMap.keySet());
			
			/*
			System.debug('Keyset: '+currPortfolioMap.keySet());
			System.debug('Conversionratemap: '+conversionRateMap);
			System.debug('Currency: '+currencyCode);
			System.debug('portfolio: '+portfolio);
			System.debug('conversionRate: '+conversionRate);
			*/
			
			//Collect all product sales item that were modified today for processing			
			return database.getQueryLocator([SELECT Id,
			Apttus_Config2__ListPrice__c,
			CurrencyIsoCode,
			Apttus_Config2__ProductCode__c,
			Apttus_Config2__ProductId__r.Portfolio__c
			FROM Apttus_Config2__PriceListItem__c
			WHERE CurrencyIsoCode = :currencyList 
			AND Apttus_Config2__ProductId__r.Portfolio__c = :portfolioList
			AND Master_Currency__c = false
			AND Apttus_Config2__PriceListId__r.Name like 'Global %'
			]);
		}
	
	/****************************************
		 * Name : execute
		 * Description : method which updates price list items according to 
		 * 		updated conversion rates
		 * Parameters: Database.BatchableContext, List of Price list items
		 * Returns : Database.QueryLocator
	 *****************************************/
	global void execute(Database.BatchableContext BC, List<Apttus_Config2__PriceListItem__c> priceListItems)
		{
			system.debug('Pricelist items'+priceListItems);
			Map<String, Decimal> priceListItemMap = new Map<String, Decimal>();
			List<String> codeList = new List<String>();	  
			
			for(Apttus_Config2__PriceListItem__c priceListItem : priceListItems)
			{
	codeList.add(priceListItem.Apttus_Config2__ProductCode__c);
			}
			
			//Get all pricelistitem details in a map for upserting data
			for(Apttus_Config2__PriceListItem__c priceListItem : [Select Id, Apttus_Config2__ProductCode__c,
			Apttus_Config2__ProductId__r.Portfolio__c,
					Apttus_Config2__ListPrice__c,
						CurrencyIsoCode
			From Apttus_Config2__PriceListItem__c 
						where Apttus_Config2__ProductCode__c in :codeList 
				 and Apttus_Config2__ProductId__r.Portfolio__c = :portfolioList
				  AND Master_Currency__c = true
				 and Apttus_Config2__PriceListId__r.Name like 'Global %'
				  //and CurrencyIsoCode != :currencyCode 
				 ])
			{
		priceListItemMap.put(priceListItem.Apttus_Config2__ProductCode__c, priceListItem.Apttus_Config2__ListPrice__c);
			}
			System.debug('priceListItemMap:'+priceListItemMap);
			
			codeList.clear();
			
			for(Apttus_Config2__PriceListItem__c plitem : priceListItems)
			{
	if(priceListItemMap.containsKey(plitem.Apttus_Config2__ProductCode__c))
	{
		Decimal listPrice = priceListItemMap.get(plitem.Apttus_Config2__ProductCode__c);
		conversionRate = conversionRateMap.get(plitem.CurrencyIsoCode+plitem.Apttus_Config2__ProductId__r.Portfolio__c);
		if(conversionRate != null)
		plitem.Apttus_Config2__ListPrice__c = (listPrice * conversionRate).setScale(2, RoundingMode.HALF_UP);
	}
			}
			Database.update(priceListItems,false); 
			
		}
	
	/****************************************
		 * Name : finish
		 * Description : finish method of batch class
		 * Parameters: Database.BatchableContext
		 * Returns : NA
	 *****************************************/
	 global void finish(Database.BatchableContext BC)
		{
			
		}
}