TITLE                     
+----------------------------------------------------------+  
Tannenbaum                                               

AUTHORS                                                  
+----------------------------------------------------------+  
Cameron Swords                                           
Rebecca Swords                                           


USAGE                                                    
+----------------------------------------------------------+  
Load "tannenbaum.scm" and call (run [filename]).         
This was all written in Petite Chez Scheme 8.4, but I do   
not have any reason to believe any R6RS-compatible         
Scheme implementation *won't* run it.                      


SYNTAX                                                   
+----------------------------------------------------------+  
 The syntax of this language is described in the top of   
 the main file, but is reproduced here:                   
                                                        
  $ -> (lexical-var 0)                                    
 $$ -> (lexical-var 1)                                    
  ( -> lambda                                             
  ) -> close lambda                                       
  @ -> application                                        
  % -> spacing                                            
  0 -> 'this line'                                        
  * -> start program                                      
  | -> end program                                        
  + -> line reference to line 1                           
  ++ -> line reference to line 2                     

+----------------------------------------------------------+
| WRITING PROGRAMS                                         |
+----------------------------------------------------------+
| Any program starts with a * (every Christmas tree has a  |
| star on top) and ends with a | (every tree has a trunk). |
|                                                          |
| Each line is a single lambda expression, and the code in |
| parens makes up the body of that lambda (and each lambda |
| is implicity single-argument); multiple arguments are    |
| 'possible' through currying in the usual fashion.        |
|                                                          |
| Any argument may be looked up in the environment using a |
| number of $s equivalent to its lexical address.          |
|                                                          |
| Functions may be called using a number of +s equal to    |
| their line number, or a 0 to reference the lambda whose  |
| body your are currently in (so 0 provides recursive      |
| abilities). Functions may also be passed in this way.    |
|                                                          |
| The two examples included are omega.tbm, which contains  |
| ((lambda (x) (x x)) (lambda (x) (x x))), and ski.tbm, in |
| which line 1 is the I combinator, line 2-3 are the K     |
| combinator, and lines 4-7 are the S combinator.          |
|                                                          |
| The very last line of any input is itself a lambda, but  |
| its body is run as the 'main', so asking for arguments   |
| in it may not be wise.                                   |
|                                                          |
| Since this language is provides the entire lambda        |
| calculus, it is necessarily Turing complete. However,    |
| good luck doing anything other than making pretty trees  |
| with it.                                                 |
+----------------------------------------------------------+
