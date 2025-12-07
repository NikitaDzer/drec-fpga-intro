#include <cstdint>
#include <cstdio>
#include <vector>

using ElemT = int16_t;

std::vector<ElemT> A;
std::vector<ElemT> B;
std::vector<ElemT> C;
int Size;

static std::vector<ElemT> CalcMatmul() {
    std::vector<ElemT> C_ref(Size * Size);

    for (int i = 0; i < Size; i++) {
      for (int j = 0; j < Size; j++) {
        ElemT Sum = 0;

        for (int k = 0; k < Size; k++) {
          Sum += A[i * Size + k] * B[j * Size + k];
        }

        C_ref[i * Size + j] = Sum;
      }
    }

    return C_ref;
}

static void PrintMatrix(const std::vector<ElemT> &Matrix) {
    for (int i = 0; i < Size; i++) {
        for (int j = 0; j < Size; j++) {
            std::printf("%5d\t", Matrix[i * Size + j]);
        }
        std::printf("\n");
    }
    std::printf("\n");
}

extern "C" void SetElemA(ElemT Elem, int Pos) { A[Pos] = Elem; }
extern "C" void SetElemB(ElemT Elem, int Pos) { B[Pos] = Elem; }
extern "C" void SetElemC(ElemT Elem, int Pos) { C[Pos] = Elem; }

extern "C" void SetSize(int NewSize) {
    Size = NewSize;
    A.reserve(Size * Size);
    B.reserve(Size * Size);
    C.reserve(Size * Size);
}

extern "C" bool VerifySA() {
    std::vector<ElemT> C_ref = CalcMatmul();
    bool Verified = true;

    std::printf("A:\n");
    PrintMatrix(A);

    std::printf("B:\n");
    PrintMatrix(B);

    std::printf("C:\n");
    PrintMatrix(C);

    std::printf("C_ref:\n");
    PrintMatrix(C_ref);

    for (int i = 0; i < Size; i++) {
        for (int j = 0; j < Size; j++) {
            ElemT c_ref = C_ref[i * Size + j];
            ElemT c     = C[i * Size + j];

            if (c_ref != c) {
                std::printf("[%d, %d] ref = %d, sa = %d (mismatch)\n", i, j, c_ref, c);
                Verified = false;
            }
        }
    }

    return Verified;
}
