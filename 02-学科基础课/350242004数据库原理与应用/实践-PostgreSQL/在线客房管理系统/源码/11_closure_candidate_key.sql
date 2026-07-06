-- ============================================================
-- 步骤11: 闭包和候选码计算结果
-- U={A,B,C,D,E,G}
-- F={AB->D, DB->EG, AC->E, BE->A, A->B}
-- ============================================================

CREATE TEMP TABLE closure_result(step_no INT, step_text TEXT);

INSERT INTO closure_result VALUES
(1, '初始: (AC)+ = {A, C}'),
(2, '由 A->B，可得 B，所以 (AC)+ = {A, B, C}'),
(3, '由 AB->D，可得 D，所以 (AC)+ = {A, B, C, D}'),
(4, '由 DB->EG，可得 E, G，所以 (AC)+ = {A, B, C, D, E, G}'),
(5, '结论: (AC)+ = U，因此AC是超码'),
(6, '候选码分析: C不出现在任何依赖右部，所有候选码必须包含C'),
(7, 'AC+ = U，且A+={A,B}，C+={C}，所以AC是候选码'),
(8, 'BC+ = U: BE->A需要E，AC->E需要A，无法仅由BC推出全部属性，因此BC不是'),
(9, 'DC+ = {D,C}，无法推出全部属性，因此DC不是'),
(10, 'EC+ = {E,C}，无法推出全部属性，因此EC不是'),
(11, 'GC+ = {G,C}，无法推出全部属性，因此GC不是'),
(12, 'LRLRN方法: L={C}, R={D,G}, LR={A,B,E}, N={}'),
(13, '必须包含L中的C，在LR中尝试组合，最小可推出U的是AC'),
(14, '全部候选码: {AC}');

SELECT * FROM closure_result ORDER BY step_no;
