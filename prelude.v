;; Virtua bootstrap.
;; Copyright (c) 2012 Manuel Simoni. See license at end of file.

($define! $quote ($vau (form) #ignore form))

($define! $sequence
   ((wrap ($vau ($seq2) #ignore
             ($seq2
                ($define! $aux
                   ($vau (head . tail) env
                      ($if (null? tail)
                           (eval head env)
                           ($seq2
                              (eval head env)
                              (eval (cons $aux tail) env)))))
                ($vau body env
                   ($if (null? body)
                        #inert
                        (eval (cons $aux body) env))))))

      ($vau (first second) env
         ((wrap ($vau #ignore #ignore (eval second env)))
          (eval first env)))))

($define! list (wrap ($vau x #ignore x)))

($define! list*
   (wrap ($vau args #ignore
            ($sequence
               ($define! aux
                  (wrap ($vau ((head . tail)) #ignore
                           ($if (null? tail)
                                head
                                (cons head (aux tail))))))
               (aux args)))))

($define! $vau
   ((wrap ($vau ($vau) #ignore
             ($vau (formals eformal . body) env
                (eval (list $vau formals eformal
                           (cons $sequence body))
                      env))))
      $vau))

($define! $lambda
   ($vau (formals . body) env
      (wrap (eval (list* $vau formals #ignore body)
                  env))))

($define! caar ($lambda (((x . #ignore) . #ignore)) x))
($define! cdar ($lambda (((#ignore . x) . #ignore)) x))
($define! cadr ($lambda ((#ignore . (x . #ignore))) x))
($define! cddr ($lambda ((#ignore . (#ignore . x))) x))

($define! apply
   ($lambda (appv arg . opt)
      (eval (cons (unwrap appv) arg)
            ($if (null? opt)
                 (make-environment)
                 (car opt)))))

($define! $cond
   ($vau clauses env

      ($define! aux
         ($lambda ((test . body) . clauses)
            ($if (eval test env)
                 (apply (wrap $sequence) body env)
                 (apply (wrap $cond) clauses env))))

      ($if (null? clauses)
           #inert
           (apply aux clauses))))

($define! not? ($lambda (x) ($if x #f #t)))

($define! get-current-environment (wrap ($vau () e e)))

($define! $set!
   ($vau (exp1 formals exp2) env
      (eval (list $define! formals
                  (list (unwrap eval) exp2 env))
            (eval exp1 env))))

($define! $provide!
   ($vau (symbols . body) env
      (eval (list $define! symbols
               (list $let ()
                  (list* $sequence body)
                  (list* list symbols)))
            env)))

($define! $import!
   ($vau (exp . symbols) env
      (eval (list $set!
                  env
                  symbols
                  (cons list symbols))
            (eval exp env))))


;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files (the "Software"), to deal in the Software without
;; restriction, including without limitation the rights to use, copy,
;; modify, merge, publish, distribute, sublicense, and/or sell copies
;; of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. REMEMBER, THERE IS NO KERNEL UNDERGROUND; IT'S ALL
;; JUST RUMOUR AND HEARSAY. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;; DEALINGS IN THE SOFTWARE.
