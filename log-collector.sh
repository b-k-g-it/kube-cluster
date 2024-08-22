#!/bin/bash

# Erstelle einen Ordner für die Logs, falls er nicht existiert
mkdir -p logs

# Funktion zum Sammeln und Speichern der Logs
collect_logs() {
    component=$1
    docker-compose logs $component > logs/${component}.log 2>&1
    echo "Logs für $component wurden in logs/${component}.log gespeichert."
}

# Sammle Logs für jede Komponente
collect_logs "kube-apiserver"
collect_logs "kube-controller-manager"
collect_logs "kube-scheduler"
collect_logs "kube-proxy"

# Erstelle eine zusammengefasste Fehlerdatei
echo "Zusammengefasste Fehler und Warnungen:" > logs/error.log
echo "======================================" >> logs/error.log
echo "" >> logs/error.log

for component in kube-apiserver kube-controller-manager kube-scheduler kube-proxy; do
    echo "Fehler und Warnungen für $component:" >> logs/error.log
    echo "-------------------------------------" >> logs/error.log
    grep -E "Error|Warning" logs/${component}.log >> logs/error.log 2>/dev/null
    echo "" >> logs/error.log
done

echo "Alle Logs wurden gesammelt und in den Ordner 'logs' gespeichert."
echo "Eine zusammengefasste Fehlerdatei wurde als 'logs/error.log' erstellt."
