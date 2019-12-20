unit uConstDef;

interface

uses
  pshare;

const
  g_TracePathTracePathSN = 'TracePath';

  g_TracePathVarFieldSN = 'VarField';
  g_TracePathNumberKN = '编号';
  g_TracePathDeviceKN = 'Device';
  g_TracePathOffsetKN = 'Offset';
  g_TracePathReceiveTimeKN = 'Receive time';
  g_TracePathFilePathKN = '文件路径';

  g_TracePathEXEPathSN = 'EXEPath';
  g_TracePathNotepadKN = 'Notepad++';

  g_TracePathTimeOptionSN = 'TimeOption';
  g_TracePathTimeMethodsKN = 'TimeMethods';
  g_TracePathStartTimeKN = 'StartTime';
  g_TracePathEndTimeKN = 'EndTime';

  //路径配置文件名TracePath.ini,与exe同一路径
  g_TraceFilePath = 'TracePath.ini';

  g_Today = '今天';
  g_Customize = '自定义';
  g_StartDate = '开始日期';
  g_EndDate = '结束日期';
  g_TRCSuffix = '.trc';

  g_ColonConnection = ':';

  //8为有效数据行数，该值由数据格式决定
  g_ValidDataNumber = 8;

var
  //参数文件路径。
  G_TraceFilePathDir: string;
implementation

end.
