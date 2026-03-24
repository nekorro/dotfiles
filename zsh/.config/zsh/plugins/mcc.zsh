if [ ! -f ~/.mccloud/n.cur ]; then
    echo odkl > ~/.mccloud/n.cur
fi
if [ ! -f ~/.mccloud/c.cur ]; then
    echo kc > ~/.mccloud/c.cur
fi
export MCC_CLOUD=$(cat ~/.mccloud/c.cur)
export MCC_NS=$(cat ~/.mccloud/n.cur)
alias m='mcc -c "$MCC_CLOUD" -n "$MCC_NS"'
alias csw='f() { echo $1 > ~/.mccloud/c.cur; export MCC_CLOUD=$1 };f'
alias nsw='f() { echo $1 > ~/.mccloud/n.cur; export MCC_NS=$1 };f'
alias ms='f() { dc=${${1#*.*.*.}%%.*}; ns=${${1#*.*.*.*.}%%.*}; [[ $ns == "one-infra" ]] && ns="infra"; mcc ssh -c $dc -n $ns $1 };f'
alias mls='f() { dc=${${1#*.*.*.}%%.*}; ns=${${1#*.*.*.*.}%%.*}; [[ $ns == "one-infra" ]] && ns="infra"; mcc log-streams -c $dc -n $ns $1 };f'
alias ml='f() { dc=${${1#*.*.*.}%%.*}; ns=${${1#*.*.*.*.}%%.*}; [[ $ns == "one-infra" ]] && ns="infra"; if [ -z $2 ]; then mcc log-streams -c $dc -n $ns $1; else mcc logs -c $dc -n $ns $1 $2; fi };f'
alias tt='f() { dc=${${1#*.*.*.}%%.*}; ns=${${1#*.*.*.*.}%%.*}; [[ $ns == "one-infra" ]] && ns="infra"; echo $dc; echo $ns };f'
