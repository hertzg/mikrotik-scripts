# required policies: read, test

:local broker [/iot/mqtt/brokers/get 0 name]
:local identity [/system/identity/get name]
:local topic "mikrotik/$identity/dhcp/lease/$leaseActMAC"

:local getCharCodeTable do={
  :global globalCharCodeTable;
  :if ([:len $globalCharCodeTable] != 256) do={
    :local nibToHex do={ :return [:pick "0123456789ABCDEF" ([:tonum $1] & 0xF)]; }
    :for from=0 to=15 counter=hNib do={
      :for from=0 to=15 counter=lNib do={
        :local hex ([$nibToHex $hNib] . [$nibToHex $lNib])
        :local char "$[[:parse "(\"\\$hex\")"]]"; #"# the quote and hash here is to fix syntax highlighting
        :set ($globalCharCodeTable->"$char") (($hNib << 4) + $lNib)
      }
    }
  }
  :return $globalCharCodeTable;
}

:local bin2JsonCharCodeArray do={
  :local index 0
  :local bytes $1
  :local charCodes $2
  :local output ""
  :while ($index < [:len $bytes]) do={
    :local char [:pick $bytes $index]
    :local byte ($charCodes->"$char")
    :if ($index > 0) do={
      :set output ($output . ",")
    }
    :set output ($output.$byte)
    :set index ($index + 1)
  }

  :return $output;
}

:local charCodes [$getCharCodeTable]
:local leaseOptions "";
:if ([:len $"lease-options"] != 0) do={
  :local index 0

  :foreach optionCode,optionBytes in=$"lease-options" do={
      :if ($index > 0) do={
          :set leaseOptions "$leaseOptions,"
      }
      :local bytesArray [$bin2JsonCharCodeArray $optionBytes $charCodes]
      :set leaseOptions "$leaseOptions\"$optionCode\":[$bytesArray]"
      :set index ($index + 1)
  };
}

:local common \
"\"leaseBound\":$leaseBound,\
\"leaseActMAC\":\"$leaseActMAC\",\
\"leaseServerName\":\"$leaseServerName\",\
\"leaseActIP\":\"$leaseActIP\",\
\"leaseHostname\":\"$"lease-hostname"\",\
\"leaseOptions\":{$leaseOptions}"

:local payload "{$common}"

/iot/mqtt/publish broker="$broker" topic="$topic" message="$payload"