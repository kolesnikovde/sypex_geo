module SypexGeo
  COUNTRY_CODES = %w[
    AP EU AD AE AF AG AI AL AM AN AO AQ AR AS AT AU AW AZ BA BB BD BE BF BG
    BH BI BJ BM BN BO BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN
    CO CR CU CV CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM
    FO FR FX GA GB GD GE GF GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN
    HR HT HU ID IE IL IN IO IQ IR IS IT JM JO JP KE KG KH KI KM KN KP KR KW
    KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD MG MH MK ML MM MN MO MP
    MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA
    PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RU RW SA SB SC SD SE SG
    SH SI SJ SK SL SM SN SO SR ST SV SY SZ TC TD TF TG TH TJ TK TM TN TO TL
    TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT RS ZA
    ZM ME ZW A1 A2 O1 AX GG IM JE BL MF
  ]

  class Result
    def initialize(position, database)
      @position = position
      @database = database
    end

    def city
      return @city if defined?(@city)
      @city = @database.read_city(@position)
    end

    def region
      city.nil? ? nil : @region ||= city[:region_seek] && @database.read_region(city[:region_seek])
    end

    def country
      seek_position = region ? region[:country_seek] : @position
      return unless seek_position

      @database.read_country(seek_position)
    end

    def country_code
      @country_code ||= begin
        country_index = if @database.country?
                          @position
                        elsif city
                          city[:country_id]
                        end

        COUNTRY_CODES[country_index - 1] if country_index
      end
    end
  end
end
