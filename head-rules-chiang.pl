#!/usr/bin/perl

%rules = (
  "ADJP" => [['first', NNS], ['first', QP], ['first', NN], ['first', '\$'], ['first', ADVP], ['first', JJ], ['first', VBN], ['first', VBG], ['first', ADJP], ['first', JJR], ['first', NP], ['first', JJS], ['first', DT], ['first', FW], ['first', RBR], ['first', RBS], ['first', SBAR], ['first', RB], ['first', '*']],
  "ADVP" => [['last', RB], ['last', RBR], ['last', RBS], ['last', FW], ['last', ADVP], ['last', TO], ['last', CD], ['last', JJR], ['last', JJ], ['last', IN], ['last', NP], ['last', JJS], ['last', NN], ['last', '*']],
  "CONJP" => [['last', CC], ['last', RB], ['last', IN], ['last', '*']],
  "FRAG" => [['first', TO], ['first', IN], ['first', VP], ['first', S], ['first', SBAR], ['first', ADJP], ['first', UCP], ['first', NP], ['first', '*']],
  "INTJ" => [['first', '*']],
  "LST" => [['last', LS], ['last', ':'], ['last', '*']],
  "NAC" => [['first', NN], ['first', NNS], ['first', NNP], ['first', NNPS], ['first', NP], ['first', NAC], ['first', EX], ['first', '\$'], ['first', CD], ['first', QP], ['first', PRP], ['first', VBG], ['first', JJ], ['first', JJS], ['first', JJR], ['first', ADJP], ['first', FW], ['first', '*']],
  "NPB" => [['last', NN, NNP, NNPS, NNS, NX, POS, JJR],
           ['last', '\$', ADJP, PRN],
           ['last', CD],
           ['last', JJ, JJS, RB, QP],
           ['last', '*']],
  "NP" => [['last', NN, NNP, NNPS, NNS, NX, POS, JJR],
           ['first', NPB, NP],
           ['last', '\$', ADJP, PRN],
           ['last', CD],
           ['last', JJ, JJS, RB, QP],
           ['last', '*']],
  "NX" => [['last', NN, NNP, NNPS, NNS, NX, POS, JJR],
           ['first', NP],
           ['last', '\$', ADJP, PRN],
           ['last', CD],
           ['last', JJ, JJS, RB, QP],
           ['last', '*']],
  "PP" => [['last', IN], ['last', TO], ['last', VBG], ['last', VBN], ['last', RP], ['last', FW], ['last', '*']],
  "PRN" => [['first', '*']],
  "PRT" => [['last', RP], ['last', '*']],
  "QP" => [['first', '\$'], ['first', IN], ['first', NNS], ['first', NN], ['first', JJ], ['first', RB], ['first', DT], ['first', CD], ['first', NCD], ['first', QP], ['first', JJR], ['first', JJS], ['first', '*']],
  "RRC" => [['last', VP], ['last', NP], ['last', ADVP], ['last', ADJP], ['last', PP], ['last', '*']],
  "S" => [['first', TO], ['first', IN], ['first', VP], ['first', S], ['first', SBAR], ['first', ADJP], ['first', UCP], ['first', NP], ['first', '*']],
  "SBAR" => [['first', WHNP], ['first', WHPP], ['first', WHADVP], ['first', WHADJP], ['first', IN], ['first', DT], ['first', S], ['first', SQ], ['first', SINV], ['first', SBAR], ['first', FRAG], ['first', '*']],
  "SBARQ" => [['first', SQ], ['first', S], ['first', SINV], ['first', SBARQ], ['first', FRAG], ['first', '*']],
  "SINV" => [['first', VBZ], ['first', VBD], ['first', VBP], ['first', VB], ['first', MD], ['first', VP], ['first', S], ['first', SINV], ['first', ADJP], ['first', NP], ['first', '*']],
  "SQ" => [['first', VBZ], ['first', VBD], ['first', VBP], ['first', VB], ['first', MD], ['first', VP], ['first', SQ], ['first', '*']],
  "UCP" => [['last', '*']],
  "VP" => [['first', TO], ['first', VBD], ['first', VBN], ['first', MD], ['first', VBZ], ['first', VB], ['first', VBG], ['first', VBP], ['first', VP], ['first', ADJP], ['first', NN], ['first', NNS], ['first', NP], ['first', '*']],
  "WHADJP" => [['first', CC], ['first', WRB], ['first', JJ], ['first', ADJP], ['first', '*']],
  "WHADVP" => [['last', CC], ['last', WRB], ['first', '*']],
  "WHNP" => [['first', WDT], ['first', WP], ['first', 'WP\$'], ['first', WHADJP], ['first', WHPP], ['first', WHNP], ['first', '*']],
  "WHPP" => [['last', IN], ['last', TO], ['last', FW], ['last', '*']],
  '*' => [['first', '*']]
    );

sub head_pos {
  my($lhs, @a) = @_;
  return -1 if $#a == -1;   # hack necessary for unescaped parens in BNC
  $rules = $rules{$lhs} || $rules{'*'};
  for $rule (@{$rules}) {
    ($pos, @nts) = @{$rule};
    if ($pos eq 'first') {
      if ($nts[0] eq '*') {
        return 0;
      }     
      for $i (0..$#a) {
        for $rule_nt (@nts) {
          if ($a[$i] eq $rule_nt) {
            return $i;
          }
        }
      }
    }
    if ($pos eq 'last') {
      if ($nts[0] eq '*') {
        return $#a;
      }     
      for $i (reverse 0..$#a) {
        for $rule_nt (@nts) {
          if ($a[$i] eq $rule_nt) {
            return $i;
          }
        }
      }
    }
  }
  die "$lhs ".join('-', @a);
}

1;
