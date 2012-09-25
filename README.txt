- Não sensível a maiúsculas/minúsculas
- Caracteres de início e fim das tags: "{" e "}"

Parâmetros comuns:
{nome_do_parâmetro [atributo=valor[ atributo=valor]]}
O nome do parâmetro não pode conter espaços, mas pode conter caracteres acentuados(?), desde
que seja referenciado da mesma forma como está definido no template.
Recomenda-se usar nomes semelhantes a identificadores no código fonte.
Exemplos: Nome, CodigoCliente.

Parâmetros especiais:

{Date|Time|DateTime [atributo=valor[ atributo=valor]]}
Date gera a data atual;
Time gera a hora atual;
DateTime gera a data e hora atuais.

Atributos gerais:
- Length: tamanho da string. Número inteiro positivo.
Se a string resultante tiver comprimento maior que o valor de Length, ela será truncada.
Se ela  tive comprimento menor que o valor de Length, serão acrescentados espaços à direita
para completar o tamanho especificado.
- Case: Upper|Lower: determina se o valor do parâmetro será convertido para maiúsculas
ou minúsculas. A ausência deste atributo mantem o valor original.

Atributos de data/hora:
- Format: string de formatação de data e hora, segundo a sintaxe do Pascal.

Em todos os casos, se o valor do atributo contiver espaços, deve ser delimitado por
aspas simples ('). Se for preciso incluir o caracter ' dentro do valor do atributo, use a
sequência \'.
Exemplos:
format=dd mm yyyy não é valido.
format='dd mm yyyy' é válido.
format='dd \'de\' mmmm \'de\' yyyy' é válido e equivale a "dd 'de' mmmm 'de' yyyy", que
resultaria, por exemplo, em "25 de janeiro de 2013".

- Loops
{loop nome_do_loop}
 ...
{/loop}

Um loop determina uma região do template sujeita a repetições. Todo o conteúdo dentro
do loop será repetido até que o programa que utiliza o template sinalize o fim do loop.

Os nomes dos parâmetros do loop devem ter o seguinte formato:
nome_do_loop.nome_do_parâmetro
Isto significa que é possível ter um parâmetro {p} em qualquer lugar do template e um
parâmetro {nome_do_loop.p} somente dentro do loop de mesmo nome, sem que haja conflitos.
se um parâmetro {p} aparecer dentro de um loop, será substituído pelo valor correspondente
como em qualquer outro lugar do texto. Os parâmetros referenciados com o nome do loop
tem escopo local e seus valores devem ser atualizados a cada iteração ou permanecerão vazios.
Os atributos se aplicam a cada parâmetro individualmente e se mantem os mesmos a cada
iteração.

Exemplo:

{loop Cliente}
Nome:       {Cliente.Nome}
Endereço:   {Cliente.Endereco length=10}

{/loop}

Se este loop tiver duas iterações, a saída será semelhante a esta:
Nome:       José da Silva
Endereço:   Rua Joaqui        --> truncado para 10 caracteres

Nome:       Pedro de Oliveira
Endereço:   Rio de Jan        --> truncado para 10 caracteres

------------------------------------------------

Exemplo de uso:

var
  Template: TStringr;
begin
  Template := TSTringr.Create('template.txt');
  Template['nome'].Valor := 'Evandro';
  Template.OnList = ProcessaLoop;
end;

procedure TMinhaClasse.ProcessaLoop(sender: TObject; Loop: TLoop; var FimLoop: boolean);
begin
  if (Loop.Nome = 'clientes') then
  begin
    Loop['nome'].Valor := 'José da Silva';
    FimLoop := True; // o evento não será mais chamado
  end;
end;
