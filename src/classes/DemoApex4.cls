@isTest
public class DemoApex4 {
private Integer num;
    
    @isTest
 	public static void helloMethod() {
        System.debug('Change Hello DemoApexClass4');
    }
    
    public static testMethod void testNewMethod() {
        System.debug('testNewMethod system debug console');
    }
}