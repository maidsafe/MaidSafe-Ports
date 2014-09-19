import port_sample
import random

testClassObject = port_sample.TestClass.RawFactoryFunction()
randomInt = random.randint(1, 1000)
print "{} {}".format("Random Int:", randomInt)
print "Passing var to C++"
testClassObject.SetMyValue(randomInt)
print "{} {}".format("Getting var from C++:", testClassObject.GetMyValue())
print "{} {}".format("Getting Static const from C++:", testClassObject.GetStaticConstValue())
print "\nDone..."
