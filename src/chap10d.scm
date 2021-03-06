;;; $Id: chap10d.scm,v 4.0 1995/07/10 06:50:37 queinnec Exp $

;;;(((((((((((((((((((((((((((((((( L i S P ))))))))))))))))))))))))))))))))
;;; This file is derived from the files that accompany the book:
;;;     LISP Implantation Semantique Programmation (InterEditions, France)
;;;     or  Lisp In Small Pieces (Cambridge University Press).
;;; By Christian Queinnec <Christian.Queinnec@INRIA.fr>
;;; The original sources can be downloaded from the author's website at
;;;   http://pagesperso-systeme.lip6.fr/Christian.Queinnec/WWW/LiSP.html
;;; This file may have been altered from the original in order to work with
;;; modern schemes. The latest copy of these altered sources can be found at
;;;   https://github.com/appleby/Lisp-In-Small-Pieces
;;; If you want to report a bug in this program, open a GitHub Issue at the
;;; repo mentioned above.
;;; Check the README file before using this file.
;;;(((((((((((((((((((((((((((((((( L i S P ))))))))))))))))))))))))))))))))

;;; Testing chap10c.scm by direct interpretation of the objectified code.

;;; This vector will contain the definitions of all lifted functions.

(define *runtime-functions* '())

(define-method (evaluate (o Flattened-Program) sr)
  (set! *runtime-functions* 
        (apply vector (reverse (Flattened-Program-definitions o))) )
  (set! sg.global 
        (append (map (lambda (qv) (cons qv (Quotation-Variable-value qv)))
                     (Flattened-Program-quotations o) )
                sg.global ) )
  (evaluate (Flattened-Program-form o) sr) )

(define-method (evaluate (e Closure-Creation) sr)
  (let ((def (vector-ref *runtime-functions* (Closure-Creation-index e))))
    (make-RunTime-Procedure 
     (Function-Definition-body def)
     (Function-Definition-variables def)
     (evaluate (Closure-Creation-free e) sr) ) ) )

(define-method (evaluate (e No-Free) sr) 
  '() )

(define-method (evaluate (e Free-Environment) sr)
  (cons (cons (Reference-variable (Free-Environment-first e))
              (evaluate (Free-Environment-first e) sr) )
        (evaluate (Free-Environment-others e) sr) ) )

(define-method (evaluate (e Free-Reference) sr)
  (cdr (assq (Free-Reference-variable e) sr)) )

(define-method (show (o Quotation-Variable) . stream)
  (let ((stream (if (pair? stream) (car stream) (current-output-port))))
    (format stream "<Quoted~A= ~A>"
            (Quotation-Variable-name o)
            (Quotation-Variable-value o) ) ) )

;;; Reuse scheme10b and test-scheme10b but update the compiler.

(define (compile-expression e)
  (extract-things! (lift! (Sexp->object e))) )

;;; end of chap10d.scm
