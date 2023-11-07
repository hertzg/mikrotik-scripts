# required policies: read, test

:local broker [/iot/mqtt/brokers/get 0 name]
:local identity [/system/identity/get name]
:local topic "mikrotik/$identity/netwatch/test/$host"

:local common \
"\"name\":\"$name\",\
\"comment\":\"$comment\",\
\"status\":\"$status\",\
\"host\":\"$host\",\
\"type\":\"$type\",\
\"interval\":$interval,\
\"since\":\"$since\",\
\"done-tests\":$"done-tests",\
\"failed-tests\":$"failed-tests""

:local extra "{}"
:if ($type = "icmp") do={
    :set extra \
    "{\"sent-count\":$"sent-count",\
    \"response-count\":$"response-count",\
    \"loss-count\":$"loss-count",\
    \"loss-percent\":$"loss-percent",\
    \"rtt-avg\":$"rtt-avg",\
    \"rtt-min\":$"rtt-min",\
    \"rtt-max\":$"rtt-max",\
    \"rtt-jitter\":$"rtt-jitter",\
    \"rtt-stdev\":$"rtt-stdev"}"
}

:if ($type = "tcp") do={
    :set extra \
    "{\"tcp-connect-time\":$"tcp-connect-time"}"
}

:if ($type = "http") do={
    :set extra \
    "{\"http-status-code\":$"http-status-code"}"
}

:if ($type = "https") do={
    :set extra \
    "{\"https-status-code\":$"https-status-code"}"
}

:local payload "{}"
:if ($type = "simple") do={
    :set payload "{$common}"
} else={
    :set payload "{$common,\"$type\":$extra}"
}

/iot/mqtt/publish broker="$broker" topic="$topic" message="$payload"