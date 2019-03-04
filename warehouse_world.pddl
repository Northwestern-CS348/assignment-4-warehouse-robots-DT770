(define (domain warehouse)
	(:requirements :typing)
	(:types robot pallette - bigobject
        	location shipment order saleitem)

  	(:predicates
    	(ships ?s - shipment ?o - order)
    	(orders ?o - order ?si - saleitem)
    	(unstarted ?s - shipment)
    	(started ?s - shipment)
    	(complete ?s - shipment)
    	(includes ?s - shipment ?si - saleitem)

    	(free ?r - robot)
    	(has ?r - robot ?p - pallette)

    	(packing-location ?l - location)
    	(packing-at ?s - shipment ?l - location)
    	(available ?l - location)
    	(connected ?l - location ?l - location)
    	(at ?bo - bigobject ?l - location)
    	(no-robot ?l - location)
    	(no-pallette ?l - location)

    	(contains ?p - pallette ?si - saleitem)
  )

   (:action startShipment
      :parameters (?s - shipment ?o - order ?l - location)
      :precondition (and (unstarted ?s) (not (complete ?s)) (ships ?s ?o) (available ?l) (packing-location ?l))
      :effect (and (started ?s) (packing-at ?s ?l) (not (unstarted ?s)) (not (available ?l)))
   )

   (:action robotMove
      :parameters (?r - robot ?l_src - location ?l_dest - location)
      :precondition (and (connected ?l_src ?l_dest)
                         (at ?r ?l_src)
                         (no-robot ?l_dest)
                    )
      :effect (and (not (at ?r ?l_src))
                   (not (no-robot ?l_dest))
                   (at ?r ?l_dest)
                   (no-robot ?l_src))
  )


   (:action robotMoveWithPallet
      :parameters (?l_src - location ?l_dest - location ?r - robot ?p - pallette)
      :precondition (and (or (free ?r) (has ?r ?p)
                         (connected ?l_src ?l_dest)
                         (at ?r ?l_src)
                         (at ?p ?l_src)
                         (no-robot ?l_dest)
                         (no-pallette ?l_dest)))
      :effect (and (has ?r ?p)
                   (not (at ?r ?l_src))
                   (not (at ?p ?l_src))
                   (at ?p ?l_dest)
                   (no-pallet ?l_src)
                   (not (no-pallette ?l_dest))
                   (at ?r ?l_dest)
                   (no-robot ?l_src)
                   (not(no-robot ?l_dest))))

    (:action moveItemFromPalletteToShipment
      :parameters (?l - location ?s - shipment ?si - saleitem ?p - pallette ?o - order)
      :precondition (and (ships ?s ?o)
                          (orders ?o ?si)
                          (started ?s)
                          (not (complete ?s ))
                          (packing-location ?l)
                          (packing-at ?s ?l)
                          (not (available ?l))
                          (at ?p ?l)
                          (contains ?p ?si)
                          (not (includes ?s ?si)))
      :effect (and (not (contains ?p ?si))
                   (includes ?s ?si)))

    (:action completeShipment
      :parameters (?s - shipment ?o - order ?l - location)
      :precondition (and (packing-at ?s ?l)
                          (ships ?s ?o)
                          (started ?s)
                          (not(complete ?s)))
      :effect (and (complete ?s)
                   (not (packing-at ?s ?l))
                   (available ?l)))
)