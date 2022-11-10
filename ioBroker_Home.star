#************************************************************#
#** Autor: Johannes Hubig <johannes.hubig@gmail.com>       **#
#** Github: https://github.com/jhubig/ioBrokerGoesTidbyt   **#
#************************************************************#

load("render.star", "render")
load("time.star", "time")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")
load("http.star", "http")
load("math.star", "math")
load("humanize.star", "humanize")
load("schema.star", "schema")

###############################################################################################################################################################
###################################################################### DEF OF ICONS ###########################################################################
###############################################################################################################################################################

BATTERY_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAXNSR0IArs4c6QAAADdJREFUGFdjZGBg+P///38GXICRkREsxQhSBeL4rA8AC2wJ3IDCBhkCkidKIdEmEq0QbDWxngEAyAA7+7P2IgAAAAAASUVORK5CYII=
""")

BIN_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAgAAAAGCAYAAAD+Bd/7AAAAAXNSR0IArs4c6QAAADxJREFUGFdtjlEOADAEQ9v7H9pW0mVsPhB9CgEElCLLCZLZM6bSMEBYMt6w7lkDbCb4C9zuDzBO14P70QXe4CP+J0FtZgAAAABJRU5ErkJggg==
""")

RED_VERTICAL_LINE = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAEAAAAcCAYAAACgXdXMAAAAAXNSR0IArs4c6QAAABBJREFUGFdj+OJs9p9hcBAAi2JD0WTWCksAAAAASUVORK5CYII=
""")

TRAIN_DIVIDER = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAB8AAAAFCAYAAAC94zfEAAAAAXNSR0IArs4c6QAAAGNJREFUKFNjdHBw+M8wQICRgYEBbPkRFhW4E2z+3IGz//9HuI2REaQcAWB6iFGPzXy45TAHIBsEEoNZjstikBpserCpB6kDOQKmnijLQQaBHIFsIMwQZMOQHQtiE1LPOJBxDgCetD+BXU0+uQAAAABJRU5ErkJggg==
""")

###############################################################################################################################################################
#################################################################### DATA FROM IOBROKER #######################################################################
###############################################################################################################################################################

SOC_Batterie        = http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/modbus.0.holdingRegisters.40083_Batterie_SOC").body()
TEMP_Outside        = http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/comfoairq.0.sensor.temperatureOutdoor").body()
DAYS_NextBin        = http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/trashschedule.0.next.daysLeft").body()
TYPE_NextBin        = http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/trashschedule.0.next.types").body()
NEXT_Train          = http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/fahrplan.0.0.0.0.DeparturePlanned").body()
NEXT_Train_Delay    = int(http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/fahrplan.0.0.0.0.DepartureDelaySeconds").body())/60



###############################################################################################################################################################

def main(config):

    # HERE YOU CAN SET YOUR TIMEZONE
    timezone = "Europe/Berlin"
    now = time.now().in_location(timezone)

    NEXT_Train          = http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/fahrplan.0.0.0.0.DeparturePlanned").body()
    NEXT_Train_Delay    = int(http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/fahrplan.0.0.0.0.DepartureDelaySeconds").body())/60

    # Be sure that the displayed train is the one after current time - ioBroker Adapter is just updated every 5 minutes - if it is the case then for next train the next data point is used
    if (time.from_timestamp(int(int(NEXT_Train)/1000)) < now):
      NEXT_Train          = http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/fahrplan.0.0.1.0.DeparturePlanned").body()
      #NEXT_Train_Delay    = int(http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/fahrplan.0.0.1.0.DepartureDelaySeconds").body())/60

    if (NEXT_Train_Delay > 9):
      space_traindelay = ""
    else:
      space_traindelay = " "

    # FONTS WHICH CAN BE USED:  10x20 tb-8 6x13 5x8 tom-thumb Dina_r400-6

    # DEFAULT FONT
    font = "tb-8"

    ##############################################################################################################################
    ########################## TRYING
    ##############################################################################################################################

    if (int(http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/0_userdata.0.TestItem").body()) == 0):
      SOC_Batterie = http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/modbus.0.holdingRegisters.40083_Batterie_SOC").body()

    elif (int(http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/0_userdata.0.TestItem").body()) == 1):
      SOC_Batterie = http.get("http://<YOUR_IOBROKER_IP>:8087/getPlainValue/0_userdata.0.ZähleriPadNeuladen").body()

    ##############################################################################################################################
    ########################## Set correct BIN_ICON
    ##############################################################################################################################

    if (TYPE_NextBin.find("Rest") > -1):
      BIN_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAgAAAAGCAYAAAD+Bd/7AAAAAXNSR0IArs4c6QAAADxJREFUGFdtjlEOADAEQ9v7H9pW0mVsPhB9CgEElCLLCZLZM6bSMEBYMt6w7lkDbCb4C9zuDzBO14P70QXe4CP+J0FtZgAAAABJRU5ErkJggg==""")

    elif (TYPE_NextBin.find("Gelb") > -1):
      BIN_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAgAAAAGCAYAAAD+Bd/7AAAAAXNSR0IArs4c6QAAAD5JREFUGFdjZGBg+M8AIl5bgyg4YBQ9CmYz/n9tDVaACzCCNIN0w3TAFMLEUBTArAEpxqoA2RoMBdjcADIJABlcIyaUQqb0AAAAAElFTkSuQmCC""")

    elif (TYPE_NextBin.find("Papier") > -1):
      BIN_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAgAAAAGCAYAAAD+Bd/7AAAAAXNSR0IArs4c6QAAAEBJREFUGFdjZGBg+M/AwMBgH7gVRMHBwfXeYDajfeBWsAJcgBFkAkg3TAdMIUwMRQHMGpBirAqQrcFQgM0NIJMASnMiRnieXMYAAAAASUVORK5CYII=""")

    elif (TYPE_NextBin.find("Bio") > -1):
      BIN_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAgAAAAGCAYAAAD+Bd/7AAAAAXNSR0IArs4c6QAAAEBJREFUGFdjZGBg+M/AwMBQGeoBouCgffUOMJuxMtQDrAAXYASZANIN0wFTCBNDUQCzBqQYqwJkazAUYHMDyCQAH/UiF3ZzFSQAAAAASUVORK5CYII=""")

    ##############################################################################################################################
    ########################## Set correct BATTERY_ICON
    ##############################################################################################################################

    # Battery between 85 and 100 %
    if (int(SOC_Batterie) == 100):
      BATTERY_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAXNSR0IArs4c6QAAADJJREFUGFdjZGBg+P///38GXICRkREsxQhS5bshEKfCzQHrGUCKiVJItIlEKwRbTaxnANFrI/u/GwrkAAAAAElFTkSuQmCC""")
      paddingLeft = 0

    elif (int(SOC_Batterie) > 85):
      BATTERY_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAXNSR0IArs4c6QAAADJJREFUGFdjZGBg+P///38GXICRkREsxQhS5bshEKfCzQHrGUCKiVJItIlEKwRbTaxnANFrI/u/GwrkAAAAAElFTkSuQmCC""")
      paddingLeft = 5

    elif (int(SOC_Batterie) > 70):
      BATTERY_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAXNSR0IArs4c6QAAADVJREFUGFdjZGBg+P///38GXICRkREsxQhS5bshEEPdlsANYDGQISDFRCkk2kSiFYKtJtYzACplL/tswlEdAAAAAElFTkSuQmCC""")
      paddingLeft = 5

    elif (int(SOC_Batterie) > 50):
      BATTERY_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAXNSR0IArs4c6QAAADVJREFUGFdjZGBg+P///38GXICRkREsxQhS5bshEEXdlsANcD7IEJBiohQSbSLRCsFWE+sZAEW1L/vUUiT2AAAAAElFTkSuQmCC""")
      paddingLeft = 5

    elif (int(SOC_Batterie) > 35):
      BATTERY_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAXNSR0IArs4c6QAAADVJREFUGFdjZGBg+P///38GXICRkREsxQhS5bshEK5uS+AGFD0gQ0CKiVJItIlEKwRbTaxnAGEFL/uWnpL6AAAAAElFTkSuQmCC""")
      paddingLeft = 5

    elif (int(SOC_Batterie) > 15):
      BATTERY_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAXNSR0IArs4c6QAAADNJREFUGFdjZGBg+P///38GXICRkREsxQhW9cYGwhE9iqEeJA1STJRCok0kWiHYamI9AwBtdyv7+7FaxAAAAABJRU5ErkJggg==""")
      paddingLeft = 5

    elif (int(SOC_Batterie) > 9):
      BATTERY_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAXNSR0IArs4c6QAAADNJREFUGFdjZGBg+P///38GXICRkREsxQhW9cYGwhE9iqEeJA1STJRCok0kWiHYamI9AwBtdyv7+7FaxAAAAABJRU5ErkJggg==""")
      paddingLeft = 5

    elif (int(SOC_Batterie) > 2):
      BATTERY_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAXNSR0IArs4c6QAAADNJREFUGFdjZGBg+P///38GXICRkREsxQhW9cYGwhE9iqEeJA1STJRCok0kWiHYamI9AwBtdyv7+7FaxAAAAABJRU5ErkJggg==""")
      paddingLeft = 10

    elif (int(SOC_Batterie) >= 1):
      BATTERY_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAXNSR0IArs4c6QAAADVJREFUGFdjZGBg+P///38GXICRkREsxQhS9dXFnIFn7ymsakGGgBQTpZBoE4lWCLaaWM8AAJnFL/tKsdrXAAAAAElFTkSuQmCC""")
      paddingLeft = 10

    elif (int(SOC_Batterie) == 0):
      BATTERY_ICON = base64.decode("""iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAXNSR0IArs4c6QAAAC9JREFUGFdjZGBg+P///38GXICRkREsxQhSBeNgUwwyBCRPlEKiTSRaIdhqYj0DAECbI/v3wtYJAAAAAElFTkSuQmCC""")
      paddingLeft = 10

    ##############################################################################################################################
    ########################## Set year with two digits
    ##############################################################################################################################

    year = "%s" % now.year
    year = year[2:4]

    ##############################################################################################################################

    ##############################################################################################################################
    ########################## Set padding for outside temperature for one and two digit values
    ##############################################################################################################################

    if (int(math.round(float(TEMP_Outside))) > 9):
      paddingLeftTemp = 4

    else:
      paddingLeftTemp = 10

    ##############################################################################################################################

    ##############################################################################################################################
    ########################## Set font color for days till next bin
    ##############################################################################################################################

    bin_days_color = "#fff"

    if (int(DAYS_NextBin) <=1 ):
      bin_days_color = "#e60000"

    ##############################################################################################################################

    return render.Root(
        delay = 500,
        child = render.Box(
            padding = 1,
            child = render.Row(
                #expanded = True,
                #main_align = 'space_between',
                children = [
                    render.Row(
                        expanded = True,
                        #main_align = 'space_between',
                        #cross_align = "center",
                        children = [
                            render.Column(

                                #cross_align = "center",
                                children = [
                                    render.Row(
                                        children=[
                                            render.Padding(
                                                pad = (2, -1, 0, 0),
                                                child = render.Text(
                                                  content = now.format("15:04"),
                                                  #font = "6x13"
                                                  #font = "5x8"
                                                  font = "Dina_r400-6"
                                                  )
                                            )
                                        ]
                                    ),
                                    render.Row(
                                        children=[
                                            render.Padding(
                                                pad = (1, 0, 0, 0),
                                                child = render.Text(
                                                  content = now.format("02") + "." + now.format("01") + "." + year,
                                                  font = "tom-thumb",
                                                  color = '#bafeff'
                                                  )
                                            )
                                        ]
                                    ),
                                    render.Row(
                                        children=[
                                            render.Padding(
                                                pad = (1, 1, 0, 0),
                                                child = render.Image(src=TRAIN_DIVIDER),
                                            )
                                        ]
                                    ),
                                    render.Row(
                                        children=[
                                          render.Padding(
                                                pad = (1, 1, 1, 0),
                                                child = render.Text(
                                                  #content = "ioBroker",
                                                  content = time.from_timestamp(int(int(NEXT_Train)/1000)).format("15:04") + space_traindelay + "+" + str(int(NEXT_Train_Delay)),
                                                  font = "tom-thumb",
                                                  #color = '#345eeb'
                                                )
                                          )
                                        ]
                                    )
                                ]
                            ),
                            render.Column(
                              children = [
                                render.Padding(
                                  pad = (1, 0, 0, 0),
                                  child = render.Image(src=RED_VERTICAL_LINE),
                              )]
                            ),
                            render.Column(

                                cross_align = "center",
                                children = [
                                    render.Row(
                                        children=[
                                        render.Padding(
                                            pad = (paddingLeft, 0, 0, 0),
                                            child = render.Text(
                                                    content = "%s" % SOC_Batterie,
                                                    font = font,
                                                )
                                        ),


                                            render.Padding(
                                                pad = (1, 1, 0, 0),
                                                child = render.Image(src=BATTERY_ICON),
                                            ),
                                        ]
                                    ),
                                    render.Row(
                                        children=[
                                          render.Padding(
                                                pad = (10, 2, 0, 0),
                                                child = render.Text(
                                                  content = "%s" % DAYS_NextBin,
                                                  font = font,
                                                  color = bin_days_color
                                                )
                                          ),
                                          render.Padding(
                                              pad = (2, 3, 0, 0),
                                              child = render.Image(src=BIN_ICON),
                                          )
                                        ]
                                    ),
                                    render.Row(
                                        cross_align = "top",
                                        children = [
                                            render.Padding(
                                                  pad = (paddingLeftTemp, 2, 0, 0),
                                                  child = render.Text(
                                                      content = "%s" % int(math.round(float(TEMP_Outside))),
                                                      font = font,
                                                      color = "#fff"
                                                  )
                                            ),
                                            render.Padding(
                                                  pad = (1, 2, 0, 0),
                                                  child = render.Text(
                                                      content = "°C",
                                                      font = font,
                                                      color = "#fff"
                                                  )
                                            )
                                        ]
                                    )
                                ]
                            )
                        ]
                    )
                ]
            )
        ),
    )
