@isTest
public class DemoApex4 {
private Integer num;
    
    @isTest
    public static void helloMethod() {
        System.debug('Change Hello DemoApexClass41');
    }
    
    public static testMethod void testNewMethod() {
        System.debug('Change Hello DemoApexClass4');
    }
}