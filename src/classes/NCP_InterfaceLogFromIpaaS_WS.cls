global with sharing class NCP_InterfaceLogFromIpaaS_WS {

	public class BulkApiJob {
		String id;
		String operation;
		String objectName;
		String status;
		String contentType;
		String numberRecordsProcessed;
		String numberRecordsFailed;

		public BulkApiJob(String id, String operation, String objectName, String status, String contentType, String numberRecordsProcessed, String numberRecordsFailed) {
			this.id = id;
			this.operation = operation;
			this.objectName = objectName;
			this.status = status;
			this.contentType = contentType;
			this.numberRecordsProcessed = numberRecordsProcessed;
			this.numberRecordsFailed = numberRecordsFailed;
		}
	}


	webservice static void CreateInterfaceLogFromIpaaS(String jobId) {
		BulkApiJob job = GetBulkApiJobDetails(jobId);
		List <Interface_Log__c> allRecords = new List <Interface_Log__c>();

		try {
			List<Interface_Log__c> successRecords = LogSuccessRecords(jobId, job);
			allRecords.addAll(successRecords);
		} catch (Exception ex) {
			System.debug('success ex >> ' + ex);
			NCP_InterfaceLog.insertInterfaceLog('CDB/CARES Interface Generic Error', 'Inbound', 'Upsert', 'CDB/CARES Interface Generic Success Error', 'Success', 'CreateInterfaceLogFromIpaaS', ex.getMessage());
		}

		try {
			List<Interface_Log__c> failureRecords = LogFailedRecords(jobId, job);
			allRecords.addAll(failureRecords);
		} catch (Exception ex) {
			System.debug('Failed ex >> ' + ex);
			NCP_InterfaceLog.insertInterfaceLog('CDB/CARES Interface Generic Error', 'Inbound', 'Upsert', 'CDB/CARES Interface Generic Failed Error', 'Failure', 'CreateInterfaceLogFromIpaaS', ex.getMessage());
		}

		try {
			insert allRecords;
		} catch (Exception ex) {
			System.debug('ex >> ' + ex);
			NCP_InterfaceLog.insertInterfaceLog('CDB/CARES Interface Generic Error', 'Inbound', 'Upsert', 'CDB/CARES Interface Generic Error', 'Failure', 'CreateInterfaceLogFromIpaaS', ex.getMessage());
		}

	}
	private static BulkApiJob GetBulkAPIJobDetails(String jobId) {
		String host = System.Url.getSalesforceBaseURL().toExternalForm();
		String relativeURL = '/services/data/v43.0/jobs/ingest/' + jobid;
		String url = host + relativeURL;
		// set the end point
		system.debug('url: ' + url);

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		HttpResponse response;

		//Get Success URL
		request.setEndpoint(url);
		request.setMethod('GET');
		String sessionId = UserInfo.getSessionId();
		// set authorization header
		request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());

		try {
			response = http.send(request);
			system.debug('response: ' + response.getBody());
			system.debug('response.getHeaderKeys(): ' + response.getHeaderKeys());

			JSONParser parser = JSON.createParser(response.getBody());
			String id;
			String objectName;
			String operation;
			String status;
			String contentType;
			String numberRecordsProcessed;
			String numberRecordsFailed;
			while (parser.nextToken() != null) {
				System.debug('parser.getCurrentToken()=' + parser.getCurrentToken() + ', parser.getCurrentName()=' + parser.getCurrentName() + ', parser.getText()=' + parser.getText());
				if (parser.getCurrentName() == 'id') {
					system.debug('id: ' + id);
					id = parser.getText();
				}
				if (parser.getCurrentName() == 'object') {
					objectName = parser.getText();
				}
				if (parser.getCurrentName() == 'operation') {
					operation = parser.getText();
				}
				if (parser.getCurrentName() == 'state') {
					status = parser.getText();
				}
				if (parser.getCurrentName() == 'contentType') {
					contentType = parser.getText();
				}
				if (parser.getCurrentName() == 'numberRecordsProcessed') {
					numberRecordsProcessed = parser.getText();
				}
				if (parser.getCurrentName() == 'numberRecordsFailed') {
					numberRecordsFailed = parser.getText();
				}
				parser.nextToken();
			}
			BulkApiJob baj = new BulkApiJob(id, operation, objectName, status, contentType, numberRecordsProcessed, numberRecordsFailed);
			system.debug('baj: ' + baj);
			return baj;
		} catch (System.Exception e) {
			System.debug('ERROR: ' + e);
			throw e;
		}
	}
	private static List <Interface_Log__c> LogSuccessRecords(String jobId, BulkApiJob job) {
		system.debug('job: ' + job);
		String host = System.Url.getSalesforceBaseURL().toExternalForm();
		String relativeURL = '/services/data/v43.0/jobs/ingest/' + jobid + '/successfulResults/';
		String url = host + relativeURL;
		// set the end point
		system.debug('url: ' + url);

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		HttpResponse response;

		//Get Success URL
		request.setEndpoint(url);
		request.setMethod('GET');
		String sessionId = UserInfo.getSessionId();
		// set authorization header
		request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
//		String[] filelines = new String[]{
//		};
		List <Interface_Log__c> interfaceLogList = new List <Interface_Log__c>();
		try {
			response = http.send(request);
			system.debug('response: ' + response.getBody());
			system.debug('response.getHeaderKeys(): ' + response.getHeaderKeys());
			system.debug('Content-Type:' + response.getHeader('Content-Type'));

			//if response is CSV
			if (response.getHeader('Content-Type') == 'text/csv') {
				String resBlobString = response.getBodyAsBlob().tostring();
				system.debug('resBlobString: ' + resBlobString);
				//Now sepatate every row of the excel file
//				filelines = resBlobString.split('\n');
				//get first csv line and separate columns
				String[] inputHeadervalues = new String[]{
				};
				String DELIMITER = '\n';
				String firstRow = resBlobString.substringBefore(DELIMITER);

				inputHeadervalues = firstRow.split(',');
				resBlobString = resBlobString.substringAfter(DELIMITER);

				Integer intCsvHeaderRecordType;
				Integer intCsvHeaderContractType;
				Integer intCsvHeaderExternalSCId;
				Integer intPriceBook2Name;
				Integer intExternalPriceBookEntryId;
				Integer intExternalCLIId;
				Integer intExternaId;

				system.debug('Start parsing csv header line. Size is iinputHeadervalues.size()=' + inputHeadervalues.size());
				for (Integer j = 0; j < inputHeadervalues.size(); j++) {
					system.debug('inputHeadervalues[' + j + ']=' + inputHeadervalues[j]);
					if (job.objectName == 'ServiceContract') {
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'recordType.Name') {
							intCsvHeaderRecordType = j;
						}
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'NCP_Contract_Type__c') {
							intCsvHeaderContractType = j;
						}
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'NCP_External_Service_Contract_Id__c') {
							intCsvHeaderExternalSCId = j;
						}
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'PriceBook2.Name') {
							intPriceBook2Name = j;
						}
					} else if (job.objectName == 'ContractLineItem') {
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'ExternalPricebookEntryId__c') {
							intExternalPriceBookEntryId = j;
						}
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'NCP_External_Contract_Line_Item_Id__c') {
							intExternalCLIId = j;
						}
					} else if (job.objectName == 'NCP_Service_Contract_Team__c') {
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'NCP_External_Id__c') {
							intExternaId = j;
						}
					} else if (job.objectName == 'NCP_Authorised_Entitlement__c') {
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'NCP_External_Id__c') {
							intExternaId = j;
							system.debug(job.objectName + ',' + inputHeadervalues[j] + ',' + intExternaId);
						}
					}

				}

				system.debug('intCsvHeaderRecordType=' + intCsvHeaderRecordType + ', intCsvHeaderContractType=' + intCsvHeaderContractType + ', intCsvHeaderExternalSCId=' + intCsvHeaderExternalSCId + ', intPriceBook2Name=' + intPriceBook2Name + ', intExternalPriceBookEntryId=' + intExternalPriceBookEntryId + ', intExternalCLIId=' + intExternalCLIId + ', intExternaId=' + intExternaId);
				//Iterate through every line
//				for (Integer i = 1; i < filelines.size(); i++) {
				while (String.isNotBlank(resBlobString)) {
					String[] inputvalues = new String[]{
					};
					String currentRow = resBlobString.substringBefore(DELIMITER);
					inputvalues = currentRow.split(',');
					// removing the first line
					resBlobString = resBlobString.substringAfter(DELIMITER);
					String recordType;
					String contractType;
					String externalSCId;
					String priceBook2Name;
					String externalPriceBookEntryId;
					String externalCLIid;
					String externaId;

					if (intCsvHeaderRecordType != null) {
						recordType = inputvalues[intCsvHeaderRecordType].replaceAll('(\r\n|\r|\")', '');
					}
					if (intCsvHeaderContractType != null) {
						contractType = inputvalues[intCsvHeaderContractType].replaceAll('(\r\n|\r|\")', '');
					}
					if (intCsvHeaderExternalSCId != null) {
						externalSCId = inputvalues[intCsvHeaderExternalSCId].replaceAll('(\r\n|\r|\")', '');
					}
					if (intPriceBook2Name != null) {
						priceBook2Name = inputvalues[intPriceBook2Name].replaceAll('(\r\n|\r|\")', '');
					}
					if (intExternalPriceBookEntryId != null) {
						externalPriceBookEntryId = inputvalues[intExternalPriceBookEntryId].replaceAll('(\r\n|\r|\")', '');
					}
					if (intExternalCLIId != null) {
						externalCLIid = inputvalues[intExternalCLIId].replaceAll('(\r\n|\r|\")', '');
					}
					if (intExternaId != null) {
						externaId = inputvalues[intExternaId].replaceAll('(\r\n|\r|\")', '');
					}
					system.debug('inputHeadervalues= ' + inputHeadervalues);
//					system.debug('inputvalues= for line ' + i + ' : ' + inputvalues);
					system.debug('job.objectName=' + job.objectName + ',recordType=' + recordType);
					Interface_Log__c log = new Interface_Log__c();
					if (job.objectName == 'ServiceContract') {
						System.debug('in if recordType= ' + recordType + ', contractType=' + contractType);
						if (recordType == 'Parent Service Contract') {
							log = NCP_InterfaceLog.createInterfaceLog(contractType + ' ' + recordType, 'Inbound', job.operation, contractType + ' ' + recordType + ' ' + externalSCId, 'Success', 'Success', firstRow + '\n' + currentRow);
							interfaceLogList.add(log);
						} else if (recordType == 'Child Service Contract') {
							contractType = priceBook2Name.remove(' Price Book');
							log = NCP_InterfaceLog.createInterfaceLog(contractType + ' ' + recordType, 'Inbound', job.operation, contractType + ' ' + recordType + ' ' + externalSCId, 'Success', 'Success', firstRow + '\n' + currentRow);
							interfaceLogList.add(log);
						}
					} else if (job.objectName == 'ContractLineItem') {
						Integer pb = externalPriceBookEntryId.indexOf(' Price Book-');
						contractType = externalPriceBookEntryId.left(pb);
						system.debug('CLI contractType:' + contractType + ', CLI externalPriceBookEntryId=' + externalPriceBookEntryId);
						log = NCP_InterfaceLog.createInterfaceLog(contractType + ' Contract Line Item', 'Inbound', job.operation, contractType + ' Contract Line Item ' + externalCLIid, 'Success', 'Success', firstRow + '\n' + currentRow);
						interfaceLogList.add(log);
					} else if (job.objectName == 'NCP_Service_Contract_Team__c') {
						system.debug('externaId:' + externaId);
						log = NCP_InterfaceLog.createInterfaceLog('Service Contract Team', 'Inbound', job.operation, 'Service Contract Team ' + externaId, 'Success', 'Success', firstRow + '\n' + currentRow);
						interfaceLogList.add(log);
					} else if (job.objectName == 'NCP_Authorised_Entitlement__c') {
						system.debug('externaId:' + externaId);
						String InterfacelogName = 'CARES Authorised Entitlement ' + externaId;
						String InterfacelogNameAbb = InterfacelogName.abbreviate(80);
						log = NCP_InterfaceLog.createInterfaceLog('CARES Authorised Entitlement', 'Inbound', job.operation, InterfacelogNameAbb, 'Success', 'Success', firstRow + '\n' + currentRow);
						interfaceLogList.add(log);
					}

				}
				system.debug('interfaceLogList.size()=' + interfaceLogList.size());

			}
			return interfaceLogList;

		} catch (System.Exception e) {
			System.debug('ERROR: ' + e);
			throw e;
		}
	}

	private static List<Interface_Log__c> LogFailedRecords(String jobId, BulkApiJob job) {
		system.debug('job: ' + job);
		String host = System.Url.getSalesforceBaseURL().toExternalForm();
		String relativeURL = '/services/data/v43.0/jobs/ingest/' + jobid + '/failedResults/';
		String url = host + relativeURL;
		// set the end point
		system.debug('url: ' + url);

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		HttpResponse response;

		//Get Success URL
		request.setEndpoint(url);
		request.setMethod('GET');
		String sessionId = UserInfo.getSessionId();
		// set authorization header
		request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
//		String[] filelines = new String[]{
//		};
		List <Interface_Log__c> interfaceLogList = new List <Interface_Log__c>();
		try {
			response = http.send(request);
			system.debug('response: ' + response.getBody());
			system.debug('response.getHeaderKeys(): ' + response.getHeaderKeys());
			system.debug('Content-Type:' + response.getHeader('Content-Type'));

			//if response is CSV
			if (response.getHeader('Content-Type') == 'text/csv') {
				String resBlobString = response.getBodyAsBlob().tostring();
				system.debug('resBlobString: ' + resBlobString);
				//Now sepatate every row of the excel file
//				filelines = resBlobString.split('\n');
				String DELIMITER = '\n';
				//get first csv line and separate columns
				String[] inputHeadervalues = new String[]{
				};

				String firstRow = resBlobString.substringBefore(DELIMITER);
				inputHeadervalues = firstRow.split(',');
				// removing the first line
				resBlobString = resBlobString.substringAfter(DELIMITER);
				Integer intCsvHeaderRecordType;
				Integer intCsvHeaderContractType;
				Integer intCsvHeaderExternalSCId;
				Integer intCsvHeaderSFError;
				Integer intPriceBook2Name;
				Integer intExternalPriceBookEntryId;
				Integer intExternalCLIId;
				Integer intExternaId;

				system.debug('Start parsing csv header line. Size is iinputHeadervalues.size()=' + inputHeadervalues.size());
				for (Integer j = 0; j < inputHeadervalues.size(); j++) {
					system.debug('inputHeadervalues[' + j + ']=' + inputHeadervalues[j]);
					if (job.objectName == 'ServiceContract') {
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'recordType.Name') {
							intCsvHeaderRecordType = j;
						}
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'NCP_Contract_Type__c') {
							intCsvHeaderContractType = j;
						}
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'NCP_External_Service_Contract_Id__c') {
							intCsvHeaderExternalSCId = j;
						}
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'sf__Error') {
							intCsvHeaderSFError = j;
						}
						if (inputHeadervalues[j] == 'PriceBook2.Name') {
							intPriceBook2Name = j;
						}
					} else if (job.objectName == 'ContractLineItem') {
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'ExternalPricebookEntryId__c') {
							intExternalPriceBookEntryId = j;
						}
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'NCP_External_Contract_Line_Item_Id__c') {
							intExternalCLIId = j;
						}
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'sf__Error') {
							intCsvHeaderSFError = j;
						}
					} else if (job.objectName == 'NCP_Service_Contract_Team__c') {
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'NCP_External_Id__c') {
							intExternaId = j;
						}
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'sf__Error') {
							intCsvHeaderSFError = j;
						}
					} else if (job.objectName == 'NCP_Authorised_Entitlement__c') {
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'NCP_External_Id__c') {
							intExternaId = j;
						}
						if (inputHeadervalues[j].replaceAll('(\r\n|\r|\")', '') == 'sf__Error') {
							intCsvHeaderSFError = j;
						}
					}
				}

				system.debug('intCsvHeaderRecordType=' + intCsvHeaderRecordType + ', intCsvHeaderContractType=' + intCsvHeaderContractType + ', intCsvHeaderExternalSCId=' + intCsvHeaderExternalSCId + ', intCsvHeaderSFError=' + intCsvHeaderSFError + ', intPriceBook2Name=' + intPriceBook2Name + ', intExternalPriceBookEntryId=' + intExternalPriceBookEntryId + ', intExternalCLIId=' + intExternalCLIId);
				//Iterate through every line
//				for (Integer i = 1; i < filelines.size(); i++) {
				while (String.isNotBlank(resBlobString)) {
					String[] inputvalues = new String[]{
					};
					String currentRow = resBlobString.substringBefore(DELIMITER);
					inputvalues = currentRow.split(',');
					// removing the first line
					resBlobString = resBlobString.substringAfter(DELIMITER);

					if (inputHeadervalues.size() != inputvalues.size()) {
						continue;
					}
					String recordType;
					String contractType;
					String externalSCId;
					String priceBook2Name;
					String sfError;
					String externalPriceBookEntryId;
					String externalCLIid;
					String externaId;
					if (intCsvHeaderRecordType != null) {
						recordType = inputvalues[intCsvHeaderRecordType].replaceAll('(\r\n|\r|\")', '');
					}
					if (intCsvHeaderContractType != null) {
						contractType = inputvalues[intCsvHeaderContractType].replaceAll('(\r\n|\r|\")', '');
					}
					if (intCsvHeaderExternalSCId != null) {
						externalSCId = inputvalues[intCsvHeaderExternalSCId].replaceAll('(\r\n|\r|\")', '');
					}
					if (intCsvHeaderSFError != null) {
						sfError = inputvalues[intCsvHeaderSFError].replaceAll('(\r\n|\r|\")', '');
					}
					if (intPriceBook2Name != null) {
						priceBook2Name = inputvalues[intPriceBook2Name].replaceAll('(\r\n|\r|\")', '');
					}
					if (intExternalPriceBookEntryId != null) {
						externalPriceBookEntryId = inputvalues[intExternalPriceBookEntryId].replaceAll('(\r\n|\r|\")', '');
					}
					if (intExternalCLIId != null) {
						externalCLIid = inputvalues[intExternalCLIId].replaceAll('(\r\n|\r|\")', '');
					}
					if (intExternaId != null) {
						externaId = inputvalues[intExternaId].replaceAll('(\r\n|\r|\")', '');
					}
					system.debug('inputHeadervalues= ' + inputHeadervalues);
//					system.debug('inputvalues= for line ' + i + ' : ' + inputvalues);
					system.debug('job.objectName=' + job.objectName + ',recordType=' + recordType + ',sfError=' + sfError + ',externalSCId=' + externalSCId + ', priceBook2Name=' + priceBook2Name + ', externalPriceBookEntryId=' + externalPriceBookEntryId + ', externalCLIid=' + externalCLIid);
					Interface_Log__c log = new Interface_Log__c();
					if (job.objectName == 'ServiceContract') {
						System.debug('in if recordType= ' + recordType + ', contractType=' + contractType);
						if (recordType == 'Parent Service Contract') {
							System.debug('in if if recordType= ' + recordType + ', contractType=' + contractType);
							log = NCP_InterfaceLog.createInterfaceLog(contractType + ' ' + recordType, 'Inbound', job.operation, contractType + ' ' + recordType + ' ' + externalSCId, 'Failure', 'Failure: ' + sfError, firstRow + '\n' + currentRow);
							interfaceLogList.add(log);
						} else if (recordType == 'Child Service Contract') {
							if (priceBook2Name != null) {
								contractType = priceBook2Name.remove(' Price Book');
								log = NCP_InterfaceLog.createInterfaceLog(contractType + ' ' + recordType, 'Inbound', job.operation, contractType + ' ' + recordType + ' ' + externalSCId, 'Failure', 'Failure: ' + sfError, firstRow + '\n' + currentRow);
								interfaceLogList.add(log);
							}
						}

					} else if (job.objectName == 'ContractLineItem') {
						Integer pb = externalPriceBookEntryId.indexOf(' Price Book-');
						contractType = externalPriceBookEntryId.left(pb);
						system.debug('CLI contractType:' + contractType + ', CLI externalPriceBookEntryId=' + externalPriceBookEntryId + ',externalCLIid=' + externalCLIid);
						log = NCP_InterfaceLog.createInterfaceLog(contractType + ' Contract Line Item', 'Inbound', job.operation, contractType + ' Contract Line Item ' + externalCLIid, 'Failure', 'Failure: ' + sfError, firstRow + '\n' + currentRow);
						interfaceLogList.add(log);
					} else if (job.objectName == 'NCP_Service_Contract_Team__c') {
						system.debug('externaId:' + externaId);
						log = NCP_InterfaceLog.createInterfaceLog('Service Contract Team', 'Inbound', job.operation, 'Service Contract Team ' + externaId, 'Failure', 'Failure: ' + sfError, firstRow + '\n' + currentRow);
						interfaceLogList.add(log);
					} else if (job.objectName == 'NCP_Authorised_Entitlement__c') {
						system.debug('externaId:' + externaId);
						String InterfacelogName = 'CARES Authorised Entitlement ' + externaId;
						String InterfacelogNameAbb = InterfacelogName.abbreviate(80);
						log = NCP_InterfaceLog.createInterfaceLog('CARES Authorised Entitlement', 'Inbound', job.operation, InterfacelogNameAbb, 'Failure', 'Failure: ' + sfError, firstRow + '\n' + currentRow);
						interfaceLogList.add(log);
					}

				}
			}
			return interfaceLogList;

		} catch (System.Exception e) {
			System.debug('ERROR: ' + e);
			throw e;
		}
	}
}