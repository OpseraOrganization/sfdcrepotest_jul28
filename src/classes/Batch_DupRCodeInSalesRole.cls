/****************************************
	 * Name : Batch_DupRCodeInSalesRole
	 * Author : Accenture
	 * Description : Sales Process Req# 3031: Role owner duplication/gap check function in Master File
	 ****************************************/
	global class Batch_DupRCodeInSalesRole implements Database.Batchable<sObject>,Database.Stateful,Schedulable 
	{
	
		  Public static String Const_Market = 'Market';
		  Public static String Const_APAC   = 'Asia Pacific & Japan';
		  Public static String Const_GCHN   = 'Greater China';
		  Public static String Const_Eur	= 'Europe';
		  Public static String Const_Ind	= 'India';
		  Public static String Const_LAT	= 'Latin America';
		  Public static String Const_NAM	= 'North America';
		  Public Static string NoDupCountry =' ';
		  Public static String Const_MEA	= 'Middle East and Africa';
		  Public static List<Messaging.Emailfileattachment> fileAttachments  = new   List<Messaging.Emailfileattachment>();								 
		  Public String csv_header = 'Grouping, Salesrole ID, Role Code, Role Name, Organisation, BG Attribute, User ID, First Name, Last Name, User Email \n';
		  public String csv_record;
		  
		  public string csv_Global = csv_header;
		  public string csv_final  = csv_header;
		  Public String csv_APAC   = csv_header;
		  Public String csv_GCHN   = csv_header;
		  Public String csv_Eur	= csv_header;
		  Public String csv_Ind	= csv_header;
		  Public String csv_LAT	= csv_header;
		  Public String csv_MEA	= csv_header;
		  Public String csv_NAM	= csv_header;
		 
		  public Integer Group_APC = 0;
		  public Integer Group_Eur = 0;
		  public Integer Group_CHN = 0;
		  public Integer Group_Ind = 0;
		  public Integer Group_LAT = 0;
		  public Integer Group_MEA = 0;
		  public Integer Group_NAM = 0;
		  public Integer Group_rem = 0;
		  public void send_mail(string file_csv,string country,string usermail)
		  {
				
				Messaging.EmailFileAttachment csv_Attach = new Messaging.EmailFileAttachment();
				Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();	
				string csvname= Label.Environment + '_' + country + '_' + Label.NF_FileName_Duplicate_Multi_level + '_'+ System.now().format('yyyy-MMM-dd-hh-mm-ss')+'.csv';
				string[] userID= usermail.split(',');	   
				if(!country.contains('All') && (file_csv != csv_header))
				{
				blob csvBlob = Blob.valueOf(file_csv);
				csv_Attach.setFileName(csvname);
				csv_Attach.setBody(csvBlob);
				if(csv_Attach != null)
				fileAttachments.add(csv_Attach);	
				}
				if((file_csv == csv_header))
				{email.setPlainTextBody(Label.NF_Email_Duplicate_Batch_No_Duplicate);
				  NoDupCountry = NoDupCountry + Country + '/'; }
				
				email.setToAddresses(userID);
				email.setSubject(csvname);
				 if(file_csv != csv_header){
				if(!Country.contains('All'))
			   { email.setPlainTextBody('Duplicate Role codes at multiple level in Sales Role table');
				 email.setFileAttachments(new Messaging.EmailFileAttachment[]{csv_Attach}); } 
				else
				{email.setFileAttachments(fileAttachments);
				string body ='';
						If(NoDupCountry!= ' ')
					   body += Label.NF_Email_Duplicate_Batch_No_Duplicate+ ' in '+NoDupCountry.removeEnd('/')+' level.';
					   else
					   body ='Duplicate Role codes at multiple level in Sales Role table.';
					   email.setHtmlBody(body);
								   }   } 
				
				if(!Test.isRunningTest())
				Messaging.SendEmailResult [] result= Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
			  
		   }

		 Public map<String,List<Sales_Role__c>> SalesRole_map = new map<String,List<Sales_Role__c>>();
		@TestVisible Private integer count = 0;
		 Public List<NF_Rolecode__c> query_RC = new List<NF_Rolecode__c>();
		 Public set<String> Rolecode_set = new set<string>();
		 Public set<String> MultiLvl_RoleSet = new set<string>();
		/********************
		*Method Name:execute 
		*Parameter:SchedulableContext SC
		*Description:Execute the bacth 
		*******************/
	  
		 global void execute(SchedulableContext SC)
		 
		 {
		   Batch_DupRCodeInSalesRole  batch= new Batch_DupRCodeInSalesRole();
			 Database.executebatch(batch,50);		   
		 
		 }
		/****************************************
		 * Name : start
		 * Author : Accenture
		 * Description : this method will contain the SOQL query for the batch 
		 *****************************************/
		global Database.QueryLocator start(Database.BatchableContext BC)
		{		   
			query_RC = [select Name, NF_Multiple_level__C,A_S__c from NF_Rolecode__C where A_S__c=true];
			for(NF_Rolecode__c get_RoleCode : query_RC){
			Rolecode_set.add(get_RoleCode.Name);
			if(get_RoleCode.NF_Multiple_level__C == true)
			MultiLvl_RoleSet.add(get_RoleCode.Name);
			}
		return Database.getQueryLocator([SELECT Id,Role_Name__c,Role_Code__c,Organisation__c, User__c, User_Email__c, First_Name__C, Last_Name__c,BG__c FROM Sales_Role__c where Role_Code__C in :Rolecode_set order by Role_Code__c DESC, BG__c DESC, Organisation__C]);
		} 
		/****************************************
		 * Name : execute
		 * Author : Accenture
		 * Description : Execution of the batch
		 *****************************************/
		global void execute(Database.BatchableContext BC, List<Sales_Role__c> sr_findDup)
		{	  
		
		List<Sales_Role__c> SR_map_list = new List<Sales_Role__c>();
		map<String,Sales_Role__c> SRmap = new map<String,Sales_Role__c>();
		
		Set<String> OrgsSet = new Set<String>();
		Set<String> RoleSet = new Set<String>();
		set<String> org_set = new set<string>();
		string SRole_code;
		string sr_key;
		
		String Initial_RoleCode;
			String Initial_Org;
		try
		{				 
			for(Sales_Role__c get_SR_obj :sr_findDup)
			{
			org_set.add(get_SR_obj.Organisation__C);
			}
			List<Territory2> territory_list = new List<Territory2>();
		
			territory_list = [SELECT Name,Hierarchy_Level__c, ParentTerritory2.Name, ParentTerritory2.ParentTerritory2.Name, ParentTerritory2.ParentTerritory2.ParentTerritory2.Name FROM Territory2 WHERE Name in :org_set and Hierarchy_level__c >= 'L4'];
			
			
			for(Sales_Role__c SR_object :sr_findDup)
			{   
			if((!SRmap.containsKey(SR_object.Role_Code__c+SR_object.Organisation__c+SR_object.BG__c)) && (!(csv_final.contains(SR_object.Role_Code__c+','+SR_object.Role_Name__c+','+SR_object.Organisation__c.replaceall(',',' ')+','+SR_object.BG__c) ))) 
			{
			SRmap.put(SR_object.Role_Code__c+SR_object.Organisation__c+SR_object.BG__c,SR_object);
			SRole_code = SR_object.Role_Code__c.subString(SR_object.Role_Code__c.lastIndexOf('_'));  
			system.debug('Role_Code__c: '+SR_object.Role_Code__c);
		
			RoleSet.add('NSNA'+SRole_code);
			RoleSet.add('NSNB'+SRole_code);
			RoleSet.add('NSNC'+SRole_code);
			RoleSet.add('NSND'+SRole_code);
			RoleSet.add('NSNE'+SRole_code);
			RoleSet.add('NSNG'+SRole_code);
			
			if(SR_object.Role_Code__c.contains('NSNA') || SR_object.Role_Code__c.contains('NSNB') )
			{
			OrgsSet.add('Nokia Networks');
			OrgsSet.add('Customer Operations');
			}
			else
			{
			for(Territory2 get_territory: territory_list)
			{
				
				if(get_territory.Name.equalsIgnoreCase(SR_object.Organisation__C) && OrgsSet.isempty())
				{
					OrgsSet.add(get_territory.Name);  
					OrgsSet.add(get_territory.ParentTerritory2.Name);
					If(get_territory.Hierarchy_Level__c >= 'L5' )
					OrgsSet.add(get_territory.ParentTerritory2.ParentTerritory2.Name);
					If(get_territory.Hierarchy_Level__c >= 'L6' )
					OrgsSet.add(get_territory.ParentTerritory2.ParentTerritory2.ParentTerritory2.Name);
				}
			}
			}
			if(!orgsSet.isempty())
			{
			for (Sales_Role__c sRole_data :[SELECT  Id,
										Role_Name__c,
										Organisation__c,
										Role_Code__c,
											User__C,
											User_Email__c,
											First_Name__C,
											Last_Name__C,
											BG__c
									FROM
										Sales_Role__c
									WHERE
										Role_Code__c in :RoleSet
										AND
										Organisation__c in :OrgsSet
										AND
										BG__c = :SR_object.BG__c] )
			{
			
			if(Rolecode_Set.contains(SRole_data.Role_Code__C))
			{
			SR_key = SRole_data.Role_Code__c+SRole_data.Organisation__c;
			if(SalesRole_map.containsKey(SR_key))			   
			{			   
			count = count + 1;
			SalesRole_map.get(SR_key).add(sRole_data);		 
			}
		   else
			{
				if(Count < 1 || (Count > 0 && MultiLvl_RoleSet.contains(SRole_data.Role_Code__C) &&  MultiLvl_RoleSet.contains(Initial_RoleCode)))
				{
				if(Count == 0)
				{
				Initial_RoleCode = SRole_data.Role_Code__c;
				Initial_Org = SRole_data.Organisation__c;
				}
				Count = Count + 1;
				List<Sales_Role__c> SRlist = new List<Sales_Role__c>();
				SRlist.add(SRole_data); 
				SalesRole_map.put(SR_key,SRlist);			
				}
			}
			}
			}
			if(Count > 1 && SalesRole_map.containsKey(SR_object.Role_Code__c+SR_object.Organisation__c) )
			{
			if(OrgsSet.contains(const_Market+' '+const_APAC)) Group_APC = Group_APC + 1;
			if(OrgsSet.contains(const_Market+' '+const_Eur))  Group_Eur = Group_Eur + 1;
			if(OrgsSet.contains(const_Market+' '+const_GCHN)) Group_CHN = Group_CHN + 1;
			if(OrgsSet.contains(const_Market+' '+const_IND))  Group_Ind = Group_Ind + 1;
			if(OrgsSet.contains(const_Market+' '+const_LAT))  Group_LAT = Group_LAT + 1;
			if(OrgsSet.contains(const_Market+' '+const_MEA))  Group_MEA = Group_MEA + 1;
			if(OrgsSet.contains(const_Market+' '+const_NAM))  Group_NAM = Group_NAM + 1;
			if(SR_object.Role_Code__c.contains('NSNA') || SR_object.Role_Code__c.contains('NSNB'))
			Group_rem = Group_rem + 1;

			for ( string key: SalesRole_map.keyset() )
			{
			SR_map_list = SalesRole_map.get(key);	   
			for( Sales_Role__c SR_ob :SR_map_list)
			{   
			if(OrgsSet.contains(SR_ob.Organisation__c))
			{
			if(SR_ob.BG__c==null)
			SR_Ob.BG__c=' ';
			  csv_record = SR_ob.Id+','+SR_ob.Role_Code__c+','+SR_ob.Role_Name__c+','+SR_ob.Organisation__c.replaceall(',',' ')+','+SR_ob.BG__c +','+SR_ob.User__c+','+SR_ob.First_Name__C+','+SR_ob.Last_Name__c+','+SR_ob.User_Email__c +'\n';
			  csv_final = csv_final + csv_record;

			  if(OrgsSet.contains(const_Market+' '+const_APAC)) csv_APAC = csv_APAC + Group_APC +','+ csv_record;
			  if(OrgsSet.contains(const_Market+' '+const_Eur))  csv_Eur =  csv_Eur  + Group_Eur +','+ csv_record;
			  if(OrgsSet.contains(const_Market+' '+const_GCHN)) csv_GCHN = csv_GCHN + Group_CHN +','+ csv_record;
			  if(OrgsSet.contains(const_Market+' '+const_IND))  csv_Ind =  csv_Ind  + Group_Ind +','+ csv_record;	
			  if(OrgsSet.contains(const_Market+' '+const_LAT))  csv_LAT =  csv_LAT  + Group_LAT +','+ csv_record;
			  if(OrgsSet.contains(const_Market+' '+const_MEA))  csv_MEA =  csv_MEA  + Group_MEA +','+ csv_record;
			  if(OrgsSet.contains(const_Market+' '+const_NAM))  csv_NAM =  csv_NAM  + Group_NAM +','+ csv_record;
						  
			  if(SR_object.Role_Code__c.contains('NSNA') || SR_object.Role_Code__c.contains('NSNB'))  
			  csv_Global = csv_Global + Group_rem +','+ csv_record;
				
				System.debug('csv_APAC'+csv_APAC);
			}
			}
			}
			}
			}
			
			count = 0;
			OrgsSet.clear();
			RoleSet.clear();
			SalesRole_map.clear();
			sr_map_list.clear();
			}
			}
		}
		catch(Exception E)
		{	
		   System.debug('Sales role duplicate Exceptions'+e.getmessage());
		}	
		}
		
		global void finish(Database.BatchableContext BC)
		{	 
		  send_mail(csv_Global, 'Global', Label.NF_Email_Duplicate_Batch_Global);
		  send_mail(csv_APAC, Const_APAC, Label.NF_Email_Duplicate_Batch_APAC);
		  send_mail(csv_GCHN, Const_GCHN, Label.NF_Email_Duplicate_Batch_GCHN);
		 send_mail(csv_Eur, Const_EUR, Label.NF_Email_Duplicate_Batch_EUROPE);
		 send_mail(csv_Ind, Const_Ind, Label.NF_Email_Duplicate_Batch_INDIA);
		  send_mail(csv_LAT, Const_LAT, Label.NF_Email_Duplicate_Batch_LAT);
		  send_mail(csv_MEA, Const_MEA, Label.NF_Email_Duplicate_Batch_MEA);
		  send_mail(csv_NAM, Const_NAM, Label.NF_Email_Duplicate_Batch_NAM);
		  send_mail(csv_record, 'All', Label.NF_Email_Duplicate_Same_Batch);
		
		}
		}