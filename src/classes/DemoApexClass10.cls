@isTest
public class DemoApexClass10 {
private Integer num;
    
    @isTest
 	public static void helloMethod() {
        System.debug('Change Hello DemoApexClass10');
    }
    
    public static testMethod void testNewMethod() {
        System.debug('Change Hello DemoApexClass10');
    }
}