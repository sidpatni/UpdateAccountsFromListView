/**
 * @description       : Code Coverage Details using tooling api
 * @author            : Siddharth Patni
 * @last modified on  : 12-22-2021
 * @last modified by  : Siddharth Patni
**/
public with sharing class CodeCoverage {
	
    /**
    * @description : makes Rest callout using tooling api to get the coverage details of classes and triggers
    * @author Siddharth Patni | 12-22-2021 
    * @return List<Wrapper> CodeCoverage Details
    **/
    @AuraEnabled
    public static List<Wrapper> getCodeCoverage(){
		List<Wrapper> wrappers = new List<Wrapper>();

        try {
			String baseURL =  'https://' + System.URL.getSalesforceBaseUrl().getHost();
			String queryStr = 'SELECT+NumLinesCovered,ApexClassOrTriggerId,ApexClassOrTrigger.Name,NumLinesUncovered,Coverage+FROM+ApexCodeCoverageAggregate';
			String ENDPOINT = baseURL + '/services/data/v40.0/tooling/';
			HttpRequest req = new HttpRequest(); 

			req.setEndpoint(ENDPOINT + 'query/?q=' + queryStr);
			req.setHeader('Authorization', 'Bearer ' + getApexSessionId());
			req.setHeader('Content-Type', 'application/json');
			req.setMethod('GET');
			req.setTimeout(80000);
				
			Http http = new Http();
			HTTPResponse res = http.send(req);
						
			Map<String, Object>  responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
			// loading data into wrappers
			for(Object obj : ((List<Object>)responseMap.get('records'))){
				Wrapper wrap = new Wrapper();
				Map<String, Object> objMap = (Map<String, Object>) obj;
				Map<String, Object> apexClassOrTriggerMap = (Map<String, Object>)objMap.get('ApexClassOrTrigger'); 
				Map<String, Object> coverageMap = (Map<String, Object>)objMap.get('Coverage');

				wrap.coveredLinesCount = Integer.valueOf(objMap.get('NumLinesCovered'));
				wrap.uncoveredLinesCount = Integer.valueOf(objMap.get('NumLinesUncovered'));
				wrap.totalLinesCount = wrap.coveredLinesCount + wrap.uncoveredLinesCount;
				wrap.className =  (String)apexClassOrTriggerMap.get('Name');
				if (wrap.coveredLinesCount > 0 || wrap.uncoveredLinesCount > 0 ){
					wrap.codeCoverage = (wrap.coveredLinesCount * 100) / (wrap.coveredLinesCount + wrap.uncoveredLinesCount);
				} else {
					wrap.codeCoverage = 0 ;
				}

				wrappers.add(wrap);
			}
		} catch (Exception e) {
			System.debug(e.getMessage());
		}
		wrappers.sort();
		return wrappers;
    }

	/**
	* @description : uses VF page to get session id
	* @author Siddharth Patni | 12-22-2021 
	* @return String sessionId
	**/
	private static String getApexSessionId() {
		String sessionId;
		PageReference reportPage = Page.SessionId;
		sessionId = reportPage.getContent().toString();
		return sessionId;  
	}

	/**
	* @description : returns code of apex class 
	* @author Siddharth Patni | 12-22-2021 
	* @param classId 
	* @return string body of classs
	**/
	@AuraEnabled
	public static string getClassOrTriggerCode(String classId){
		try {
			String classBody = [SELECT Body FROM ApexClass WHERE Id = :classId LIMIT 1].Body;
			System.debug(classBody);
			return classBody;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	
	public class Wrapper implements Comparable {
		@AuraEnabled 
		public String className ;
		@AuraEnabled 
		public Integer coveredLinesCount ;
		@AuraEnabled 
		public Integer uncoveredLinesCount ;
		@AuraEnabled 
		public Integer totalLinesCount ;
		@AuraEnabled 
		public Double codeCoverage ;

		public Integer compareTo(Object compareTo) 
		{
			Wrapper compareToEmp = (Wrapper)compareTo;
            if (className == compareToEmp.className) return 0;
            if (className > compareToEmp.className) return 1;
            return -1;  
		}
	}
}
