public class FutureClass {
    
    public FutureClass(){
        method1();
        method2();
        method3();
        method4();
    }
    
    public static void method1(){
        system.debug('inside method1');
    }
	@future
    public static void method2(){
        system.debug('inside method2');
    }
    
    public static void method3(){
        system.debug('inside method3');
    }
    
    public static void method4(){
        system.debug('inside method4');
    }
}