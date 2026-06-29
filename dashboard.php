<?php
$url = "http://localhost/api/v1/estudiantes/notas";
$target_sli = 500; // Objetivo en milisegundos

while (true) {
    $start_time = microtime(true);
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 2);
    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    $end_time = microtime(true);
    $latency = round(($end_time - $start_time) * 1000);

    // Limpia la terminal en cada ciclo para simular un refresco visual
    system('clear');

    echo "=============================================================\n";
    echo "      SRE TERMINAL DASHBOARD - CONTROL DE ESTUDIANTES PUCE   \n";
    echo "=============================================================\n";
    echo " Fecha/Hora: " . date('Y-m-d H:i:s') . "\n";
    echo "-------------------------------------------------------------\n";

    if ($http_code === 200) {
        echo " STATUS DE LA PLATAFORMA:  \e[42m\e[30m  ONLINE  \e[0m (HTTP 200)\n";
        
        if ($latency < $target_sli) {
            echo " LATENCIA ACTUAL API:      \e[32m{$latency} ms\e[0m (Dentro de rango seguro)\n";
            echo " CUMPLIMIENTO DEL SLI:     \e[32m[ CUMPLIENDO ]\e[0m\n";
        } else {
            echo " LATENCIA ACTUAL API:      \e[31m{$latency} ms\e[0m (¡ALERTA DE SATURACIÓN!)\n";
            echo " CUMPLIMIENTO DEL SLI:     \e[33m[ FUERA DE RANGO ]\e[0m\n";
        }
    } else {
        echo " STATUS DE LA PLATAFORMA:  \e[41m\e[37m  CRÍTICO  \e[0m (Sistema No Responde)\n";
        echo " LATENCIA ACTUAL API:      \e[31m-- ms\e[0m\n";
        echo " CUMPLIMIENTO DEL SLI:     \e[31m[ VIOLADO - INFRAESTRUCTURA CAÍDA ]\e[0m\n";
    }

    echo "-------------------------------------------------------------\n";
    echo " Generando logs automáticos en: ~/control-estudiantes/sli.log\n";
    echo " Presiona [Ctrl + C] para detener el monitoreo SRE.\n";
    echo "=============================================================\n";

    // Guardar histórico en archivo log
    $log_message = "[" . date('Y-m-d H:i:s') . "] Code: $http_code | Latency: {$latency}ms\n";
    file_put_contents('sli.log', $log_message, FILE_APPEND);

    sleep(2);
}
