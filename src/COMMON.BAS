
SUB Startup
SCREEN 0: WIDTH 80

IF LEN(DIR$("GFX\*.*")) = 0 THEN
        PRINT "Cannot find GFX directory. Be sure to set the working directory correctly."
        END
END IF

END SUB

