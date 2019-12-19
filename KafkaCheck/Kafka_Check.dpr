program Kafka_Check;

uses
  Forms,
  KafkaCheck in 'KafkaCheck.pas' {KafkaCheckForm},
  pfmSelDate in 'pfmSelDate.pas' {fmSelDate},
  uConstDef in 'uConstDef.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TKafkaCheckForm, KafkaCheckForm);
  Application.CreateForm(TfmSelDate, fmSelDate);
  Application.Run;
end.
