;;;; Welcome to your first Halite-II bot in Common Lisp!
;;;;
;;;; The bot's name is Settler.  It executes a very simple algorithm:
;;;;
;;;; 1. Initialize the game
;;;;
;;;; 2. If a ship is not docked and there are unowned planets.
;;;; 2.a Try to dock the planet if it is close enough.
;;;; 2.b If not, move towards that planet.

(defpackage :mybot
  (:use :common-lisp)
  (:export #:mybot))

(in-package :mybot)

(defvar *game*)

(defvar *logfile*)

(defun mybot ()
  ;; Initialize the game.
  (let* ((*game* (hlt:make-game :bot-name "Settler"))
         ;; Set up logging
         (*logfile* (open (multiple-value-bind (second minute hour day month year)
                              (get-decoded-time)
                            (format nil "~D-~D-~DT~2,'0D:~2,'0D:~2,'0D-~D-~A.log"
                                    year month day hour minute second
                                    (hlt:user-id *game*)
                                    (hlt:bot-name *game*)))
                          :direction :output
                          :element-type 'extended-char
                          :external-format :utf-8
                          :if-exists :supersede)))
    ;; Optional: Describe what your bot is doing.
    (format *logfile* "Settler bot is now up and running!~%")
    (loop
      (finish-output *logfile*)
      (let* ((map (hlt:current-map *game*))
             (active-player (hlt:nth-player (hlt:user-id *game*) map)))
        ;; Search all of your ships.
        (loop for ship in (hlt:ships active-player)
              ;; Skip ships that are currently docking.
              unless (hlt:ship-docking-p ship) do
                ;; Search all planets.
                (loop for planet in (hlt:planets map)
                      ;; Skip planets that are already owned.
                      unless (hlt:planet-owned-p planet) do
                        ;; Either try to dock, or try to move closer to the
                        ;; planet.
                        (or (hlt:issue-dock-command ship planet)
                            (hlt:issue-navigate-command
                             ship
                             :target (hlt:closest-point-to ship planet)
                             :speed (floor hlt:+max-speed+ 2)
                             :ignore-ships t))))
        ;; Send all the issued commands to the game server.
        (hlt:finalize-turn *game*)))))
