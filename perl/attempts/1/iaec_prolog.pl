precond(pdftotext,
        [
	 hasType(dataIdFn(InputDataID),contentsFn(pdfFile))
        ],
	[
	 hasType(dataIdFn(OutputDataID),funcall(pdftotext,contentsFn(pdfFile))),
	 hasType(dataIdFn(OutputDataID),text)
        ]).
